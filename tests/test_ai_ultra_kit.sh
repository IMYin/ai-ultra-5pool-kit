#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_TEST="$(mktemp -d "${TMPDIR:-/tmp}/ai_ultra_test.XXXXXX")"
trap 'rm -rf "$TMP_TEST"' EXIT

echo "1) Syntax checks..."
bash -n "$ROOT/bin/ai-link"
bash -n "$ROOT/bin/dev-external"
bash -n "$ROOT/skills/colab-gpu-offload/scripts/colab_zero_leak.sh"

echo "2) Testing ai-link --init-hub & project linking..."
export HOME="$TMP_TEST/home"
mkdir -p "$HOME/.agents/skills/demo-skill"
cat > "$HOME/.agents/skills/demo-skill/SKILL.md" <<'EOF'
---
name: demo-skill
description: Demo skill for bidirectional sync verification.
---
# Demo
EOF

export AI_HUB_DIR="$TMP_TEST/cloud/AI-Projects"
"$ROOT/bin/ai-link" --init-hub >/dev/null
test -f "$AI_HUB_DIR/_REGISTRY.md"
test -f "$AI_HUB_DIR/_GLOBAL_INBOX.md"

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

echo "3) Testing ai-link --sync-skills (local -> cloud & cloud -> local)..."
mkdir -p "$AI_HUB_DIR/_skills/cloud-only-skill"
cat > "$AI_HUB_DIR/_skills/cloud-only-skill/SKILL.md" <<'EOF'
---
name: cloud-only-skill
description: Created in cloud web UI.
---
# Cloud Skill
EOF

"$ROOT/bin/ai-link" --sync-skills >/dev/null
test -f "$AI_HUB_DIR/_skills/demo-skill/SKILL.md"
test -f "$AI_HUB_DIR/_skills/_INDEX.md"
test -f "$HOME/.agents/skills/cloud-only-skill/SKILL.md"
"$ROOT/bin/ai-link" --list-skills | grep -Fq "demo-skill"

echo "4) Testing dev-external fail-closed behavior & help..."
"$ROOT/bin/dev-external" --help >/dev/null
if DEV_EXTERNAL_CFG="$TMP_TEST/missing.env" "$ROOT/bin/dev-external" true 2>/dev/null; then
  echo "FAIL: dev-external should fail when unconfigured" >&2
  exit 1
fi
if DEV_EXTERNAL_MOUNT="$TMP_TEST/not-mounted" DEV_EXTERNAL_UUID="0000-0000" "$ROOT/bin/dev-external" true 2>/dev/null; then
  echo "FAIL: dev-external should fail closed when volume is missing" >&2
  exit 1
fi

echo "5) Testing colab_zero_leak.sh help & cleanup trap with stub colab..."
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
COLAB_BIN="$STUB_BIN/colab" "$ROOT/skills/colab-gpu-offload/scripts/colab_zero_leak.sh" \
  test-sess "$JOB_PY" /content/scratch/out.bin "$TMP_TEST/out/out.bin" --drive >/dev/null
grep -Fq "new -s test-sess --gpu L4" "$LOG_FILE"
grep -Fq "drivemount -s test-sess" "$LOG_FILE"
grep -Fq "stop -s test-sess" "$LOG_FILE"
grep -Fq "sessions" "$LOG_FILE"

echo "✅ All ai-ultra-5pool-kit tests passed!"
