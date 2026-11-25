#!/usr/bin/env bash
set -euo pipefail

# Zero-Leak Colab L4 runner using google-colab-cli (`colab`).
# Ensures cleanup on success, error, or Ctrl-C via `trap cleanup EXIT`.

usage() {
  cat <<'EOF'
Usage:
  colab_zero_leak.sh [--drive] <session-name> <local-script.py> [remote-artifact-path] [local-dest-path]

Options:
  --drive      Mount Google Drive inside the Colab VM before running the script

Environment overrides:
  COLAB_BIN    Path to colab CLI (default: colab)
  COLAB_GPU    GPU type passed to `colab new` (default: L4)
EOF
}

MOUNT_DRIVE=0
POS_ARGS=()
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    --drive)
      MOUNT_DRIVE=1
      ;;
    *)
      POS_ARGS+=("$arg")
      ;;
  esac
done

if [ "${#POS_ARGS[@]}" -lt 2 ]; then
  usage
  exit 2
fi

SESSION="${POS_ARGS[0]}"
SCRIPT_PATH="${POS_ARGS[1]}"
REMOTE_OUT="${POS_ARGS[2]:-}"
LOCAL_OUT="${POS_ARGS[3]:-}"

if [ ! -f "$SCRIPT_PATH" ]; then
  echo "❌ Script not found: $SCRIPT_PATH" >&2
  exit 1
fi

COLAB="${COLAB_BIN:-colab}"
GPU="${COLAB_GPU:-L4}"

cleanup() {
  echo "=== [Zero-Leak] Stopping Colab session: $SESSION ==="
  "$COLAB" stop -s "$SESSION" || true
  "$COLAB" sessions || true
}
trap cleanup EXIT

"$COLAB" new -s "$SESSION" --gpu "$GPU"
if [ "$MOUNT_DRIVE" -eq 1 ]; then
  "$COLAB" drivemount -s "$SESSION"
fi
"$COLAB" exec -s "$SESSION" --timeout 0 -f "$SCRIPT_PATH"

if [ -n "$REMOTE_OUT" ] && [ -n "$LOCAL_OUT" ]; then
  mkdir -p "$(dirname "$LOCAL_OUT")"
  "$COLAB" download -s "$SESSION" "$REMOTE_OUT" "$LOCAL_OUT"
  echo "✅ Downloaded $REMOTE_OUT -> $LOCAL_OUT"
fi
