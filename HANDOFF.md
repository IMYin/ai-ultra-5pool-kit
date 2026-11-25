# HANDOFF — ai-ultra-5pool-kit

## Project goal
Provide the open-source CLI helpers (`ai-link`, `dev-external`), Agent Skills (`colab-gpu-offload`, `ai-cloud-sync`), and plain-text templates supporting the 5-pool multi-engine developer workflow.

## Structure
- `bin/ai-link` — `.ai/` symlink manager, worktree-safe `.git/info/exclude` injector, and bidirectional plain-text skill syncer.
- `bin/dev-external` — macOS `diskutil`/`plutil` `VolumeUUID` fail-closed `TMPDIR` guard.
- `skills/` — `colab-gpu-offload` (+ `colab_zero_leak.sh`) and `ai-cloud-sync`.
- `templates/` — `CONTEXT`, `STATUS`, `INBOX`, `HANDOFF`, `AISTUDIO-SYSTEM-INSTRUCTIONS.md`, `GLOBAL-AGENT-RULES.md`, `skills.example.json`.
- `tests/test_ai_ultra_kit.sh` — offline end-to-end test suite.

## Run tests
```bash
bash tests/test_ai_ultra_kit.sh
```

## Data and configuration
- Zero personal paths, hardware UUIDs, emails, or secrets committed. Runtime configs live in `~/.config/dev-external/config.env` and optional `~/.config/ai-link/skills.json`.
