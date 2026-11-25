#!/usr/bin/env bash
set -euo pipefail

# Zero-Leak Colab L4 runner using google-colab-cli (`colab`).
# Ensures cleanup on success, error, or Ctrl-C via `trap cleanup EXIT`.

usage() {
  cat <<'EOF'
Usage:
  colab_zero_leak.sh <session-name> <local-script.py> [remote-artifact-path] [local-dest-path] [--drive]

Environment overrides:
  COLAB_BIN    Path to colab CLI (default: colab)
  COLAB_GPU    GPU type passed to `colab new` (default: L4)
  EXEC_PREFIX  Optional wrapper prefix (e.g. dev-external)
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] || [ "$#" -lt 2 ]; then
  usage
  [ "$#" -lt 2 ] && [ "${1:-}" != "-h" ] && [ "${1:-}" != "--help" ] && exit 2 || exit 0
fi

SESSION="$1"
SCRIPT_PATH="$2"
REMOTE_OUT="${3:-}"
LOCAL_OUT="${4:-}"
MOUNT_DRIVE=0
for arg in "$@"; do
  [ "$arg" = "--drive" ] && MOUNT_DRIVE=1
done

if [ ! -f "$SCRIPT_PATH" ]; then
  echo "❌ Script not found: $SCRIPT_PATH" >&2
  exit 1
fi

COLAB="${COLAB_BIN:-colab}"
GPU="${COLAB_GPU:-L4}"
run_colab() {
  if [ -n "${EXEC_PREFIX:-}" ]; then
    "$EXEC_PREFIX" "$COLAB" "$@"
  else
    "$COLAB" "$@"
  fi
}

cleanup() {
  echo "=== [Zero-Leak] Stopping Colab session: $SESSION ==="
  run_colab stop -s "$SESSION" || true
  run_colab sessions || true
}
trap cleanup EXIT

run_colab new -s "$SESSION" --gpu "$GPU"
if [ "$MOUNT_DRIVE" -eq 1 ]; then
  run_colab drivemount -s "$SESSION"
fi
run_colab exec -s "$SESSION" --timeout 0 -f "$SCRIPT_PATH"

if [ -n "$REMOTE_OUT" ] && [ -n "$LOCAL_OUT" ]; then
  mkdir -p "$(dirname "$LOCAL_OUT")"
  run_colab download -s "$SESSION" "$REMOTE_OUT" "$LOCAL_OUT"
  echo "✅ Downloaded $REMOTE_OUT -> $LOCAL_OUT"
fi
