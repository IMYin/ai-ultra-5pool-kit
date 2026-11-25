# Global Agent Execution Rules (Snippet for `~/.gemini/GEMINI.md` or `~/.claude/CLAUDE.md`)

## External SSD Guard (`dev-external`)
- Prefix heavy build, test, dependency, and rendering commands with `dev-external`:
  ```bash
  dev-external <command> [args...]
  ```
- `dev-external` verifies the external SSD `VolumeUUID` and routes `TMPDIR` to external storage. If the volume is missing or fails validation, fail closed—never silently drop `dev-external` to fall back to internal `/tmp`.

## Colab L4 GPU Offload (`google-colab-cli`)
- Offload heavy VRAM inference, F5-TTS voice cloning, Whisper alignment, batch headless browser rendering, and high-bandwidth archive scans to `colab --gpu L4` following `skills/colab-gpu-offload/SKILL.md`.
- Always compute in `/content/scratch/`, keep remote stdout under 50 lines, and verify zero active instances via `colab stop -s <name> && colab sessions`.

## Cloud Context Bus (`.ai/`)
- When working inside any repository containing `.ai/`, read `.ai/CONTEXT.md`, `.ai/STATUS.md`, and `.ai/INBOX.md` at session start, and update `.ai/STATUS.md` before finishing.
