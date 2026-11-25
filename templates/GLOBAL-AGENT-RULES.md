# Global Agent Execution Rules (Snippet for `~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`, or Cursor Rules)

## Cloud Context Bus (`.ai/`)
- When working inside any repository containing `.ai/`, read `.ai/CONTEXT.md`, `.ai/STATUS.md`, and `.ai/INBOX.md` at session start.
- Process any pending specifications referenced in `.ai/INBOX.md` and `.ai/specs/`.
- Update `.ai/STATUS.md` and clear completed inbox entries before finishing.
- Keep all `.ai/` files in plain Markdown (`.md`) or `.json` (never proprietary online doc shortcuts).

## Colab L4 GPU Offload (`google-colab-cli`)
- Offload heavy VRAM inference, voice/audio batch pipelines, parallel headless browser rendering, and large dataset fetches to `colab --gpu L4` following `skills/colab-gpu-offload/SKILL.md`.
- Run heavy intermediate file writes inside `/content/scratch/` rather than `/content/drive` FUSE mounts.
- Keep remote script stdout under 50 lines and verify zero active instances via `colab stop -s <name> && colab sessions`.
