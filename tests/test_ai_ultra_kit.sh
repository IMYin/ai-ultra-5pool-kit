#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_TEST="$(mktemp -d "${TMPDIR:-/tmp}/ai_ultra_test.XXXXXX")"
trap 'rm -rf "$TMP_TEST"' EXIT

echo "1) Syntax checks..."
bash -n "$ROOT/bin/ai-link"
bash -n "$ROOT/skills/colab-gpu-offload/scripts/colab_zero_leak.sh"

echo "2) Testing ai-link --set-hub, --init-hub, link, and --unlink..."
export HOME="$TMP_TEST/home"
export AI_LINK_CFG="$TMP_TEST/cfg/config.env"
unset AI_HUB_DIR GDRIVE_ROOT || true

HUB_DIR="$TMP_TEST/cloud/AI-Projects"
"$ROOT/bin/ai-link" --set-hub "$HUB_DIR" >/dev/null
test -f "$AI_LINK_CFG"
"$ROOT/bin/ai-link" --init-hub >/dev/null
test -f "$HUB_DIR/_REGISTRY.md"
test -f "$HUB_DIR/_GLOBAL_INBOX.md"

REPO_DIR="$TMP_TEST/my-sample-repo"
mkdir -p "$REPO_DIR"
git -C "$REPO_DIR" init -b main >/dev/null 2>&1
(cd "$REPO_DIR" && "$ROOT/bin/ai-link" >/dev/null)

test -L "$REPO_DIR/.ai"
test -f "$REPO_DIR/.ai/CONTEXT.md"
test -f "$REPO_DIR/.ai/STATUS.md"
test -f "$REPO_DIR/.ai/INBOX.md"
test -d "$REPO_DIR/.ai/specs"
grep -qxF ".ai" "$REPO_DIR/.git/info/exclude"
grep -Fq "## Cloud Context Sync (.ai/)" "$REPO_DIR/AGENTS.md"
"$ROOT/bin/ai-link" --list | grep -Fq "my-sample-repo"

(cd "$REPO_DIR" && "$ROOT/bin/ai-link" --unlink >/dev/null)
test ! -L "$REPO_DIR/.ai"
! grep -qxF ".ai" "$REPO_DIR/.git/info/exclude"

echo "3) Testing ai-link --sync-skills (local -> cloud & cloud -> local + ignore list)..."
mkdir -p "$HOME/.agents/skills/demo-skill" "$HOME/.agents/skills/skip-skill"
cat > "$HOME/.agents/skills/demo-skill/SKILL.md" <<'EOF'
---
name: demo-skill
description: Demo skill for bidirectional sync verification.
---
# Demo
EOF
cat > "$HOME/.agents/skills/skip-skill/SKILL.md" <<'EOF'
---
name: skip-skill
description: Should be excluded by ignore list.
---
# Skip
EOF

export AI_LINK_SKILLS_CFG="$TMP_TEST/cfg/skills.json"
echo '{"ignore": ["skip-skill"], "skills": []}' > "$AI_LINK_SKILLS_CFG"

mkdir -p "$HUB_DIR/_skills/cloud-only-skill"
cat > "$HUB_DIR/_skills/cloud-only-skill/SKILL.md" <<'EOF'
---
name: cloud-only-skill
description: Created in cloud web UI.
---
# Cloud Skill
EOF

"$ROOT/bin/ai-link" --sync-skills >/dev/null
test -f "$HUB_DIR/_skills/demo-skill/SKILL.md"
test ! -d "$HUB_DIR/_skills/skip-skill"
test -f "$HUB_DIR/_skills/_INDEX.md"
test -f "$HOME/.agents/skills/cloud-only-skill/SKILL.md"
"$ROOT/bin/ai-link" --list-skills | grep -Fq "demo-skill"

echo "4) Testing colab_zero_leak.sh (--drive flag parsing & trap cleanup)..."
"$ROOT/skills/colab-gpu-offload/scripts/colab_zero_leak.sh" --help >/dev/null
STUB_BIN="$TMP_TEST/stub_bin"
mkdir -p "$STUB_BIN"
LOG_FILE="$TMP_TEST/colab_calls.log"
cat > "$STUB_BIN/colab" <<EOF
#!/usr/bin/env bash
echo "\$*" >> "$LOG_FILE"
exit 0
EOF
chmod +x "$STUB_BIN/colab"
JOB_PY="$TMP_TEST/job.py"
echo "print('ok')" > "$JOB_PY"

# Case A: --drive with download paths
COLAB_BIN="$STUB_BIN/colab" "$ROOT/skills/colab-gpu-offload/scripts/colab_zero_leak.sh" \
  --drive test-sess-a "$JOB_PY" /content/scratch/out.bin "$TMP_TEST/out/out.bin" >/dev/null
grep -Fq "new -s test-sess-a --gpu L4" "$LOG_FILE"
grep -Fq "drivemount -s test-sess-a" "$LOG_FILE"
grep -Fq "download -s test-sess-a /content/scratch/out.bin" "$LOG_FILE"
grep -Fq "stop -s test-sess-a" "$LOG_FILE"
grep -Fq "sessions" "$LOG_FILE"

# Case B: --drive WITHOUT download paths (must not trigger download)
: > "$LOG_FILE"
COLAB_BIN="$STUB_BIN/colab" "$ROOT/skills/colab-gpu-offload/scripts/colab_zero_leak.sh" \
  test-sess-b "$JOB_PY" --drive >/dev/null
! grep -Fq "download" "$LOG_FILE"
grep -Fq "drivemount -s test-sess-b" "$LOG_FILE"
grep -Fq "stop -s test-sess-b" "$LOG_FILE"

echo "✅ All ai-ultra-5pool-kit tests passed!"
