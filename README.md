# ai-ultra-5pool-kit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Turn 1 Subscription into a 5-Pool Cloud Compute Fleet** — Companion open-source toolkit for cross-device `.ai/` context syncing, macOS external SSD `VolumeUUID` protection, Google AI Studio cloud specs, and Zero-Leak Colab L4 GPU offloading.

Companion scripts, templates, and Agent Skills from the article & video *"How to Turn \$100 Google AI Ultra into \$1,200+ Compute"* (*把 100 刀 Gemini 花出 1200 刀效果*).

## Architecture Overview

Instead of burning local IDE/CLI agent quota on everything, split workloads cleanly across 5 isolated quota pools connected by a Google Drive plain-text bus (`.ai/`):

| Pool | Reset / Billing | Best Workloads | Tooling in This Repo |
| :--- | :--- | :--- | :--- |
| **1. Local Coding Agent** | Rolling window | Multi-file edits, builds, tests, git ops | `bin/ai-link`, `skills/ai-cloud-sync/` |
| **2. Cloud Web / Deep Research + Drive** | Rolling window + Cloud Storage | Architecture & multi-device memory bus | `bin/ai-link` (`.ai/` symlink + `--sync-skills`) |
| **3. AI Studio Web UI** | Daily free web quota | 1M-token reading, JSON specs, video QA | `templates/AISTUDIO-SYSTEM-INSTRUCTIONS.md` |
| **4. Colab GPU (`google-colab-cli`)** | Monthly CU (`--gpu L4`) | Headless Chrome video render, TTS, ML | `skills/colab-gpu-offload/` |
| **5. Cloud Promotional Credits / API** | Billing credits | Cloud infra + overflow model API calls | Standard GCP / Gemini API setup |

Companion OSS projects in this creator stack:
- **Video pipeline**: [`IMYin/remotion-explainer-video`](https://github.com/IMYin/remotion-explainer-video) — Wide-gap SRT → voice-clone tightening → Remotion v4 → Colab L4 render → 120 BPM BGM/SFX master
- **WeChat publishing**: [`IMYin/wechat-draft-publisher`](https://github.com/IMYin/wechat-draft-publisher) — Markdown → dual-cover safe HTML → fixed-IP SSH relay → WeChat Draft Box
- **Human Chinese writing**: [`IMYin/chinese-human-voice`](https://github.com/IMYin/chinese-human-voice)

## What's Inside

```text
ai-ultra-5pool-kit/
├── bin/
│   ├── ai-link                         # .ai/ symlink bridge + .git/info/exclude + bidirectional skill sync
│   └── dev-external                    # Fail-closed macOS external SSD VolumeUUID guard & TMPDIR router
├── skills/
│   ├── ai-cloud-sync/SKILL.md          # Agent skill for reading/writing .ai/CONTEXT|STATUS|INBOX
│   └── colab-gpu-offload/
│       ├── SKILL.md                    # 5 Zero-Leak & /content/scratch/ iron laws for google-colab-cli
│       └── scripts/colab_zero_leak.sh  # trap cleanup EXIT wrapper (never leaves idle Colab VMs)
├── templates/
│   ├── CONTEXT.template.md
│   ├── STATUS.template.md
│   ├── INBOX.template.md
│   ├── HANDOFF-FOR-AGENT.template.md
│   ├── AISTUDIO-SYSTEM-INSTRUCTIONS.md # Web UI preset for Google Drive-attached research
│   ├── GLOBAL-AGENT-RULES.md           # Global rules snippet for Claude Code / Antigravity / Codex
│   └── skills.example.json             # Optional ~/.config/ai-link/skills.json override
└── tests/
    └── test_ai_ultra_kit.sh            # Offline automated verification suite
```

## Quick Start

### 1. Install the CLI helpers & Agent Skills

```bash
git clone https://github.com/IMYin/ai-ultra-5pool-kit.git
cd ai-ultra-5pool-kit

mkdir -p ~/.local/bin ~/.agents/skills ~/.claude/skills
cp bin/ai-link bin/dev-external ~/.local/bin/
chmod +x ~/.local/bin/ai-link ~/.local/bin/dev-external

cp -r skills/ai-cloud-sync skills/colab-gpu-offload ~/.agents/skills/
# For Claude Code users:
cp -r skills/ai-cloud-sync skills/colab-gpu-offload ~/.claude/skills/
```

Ensure `~/.local/bin` is on your `PATH`.

### 2. Configure `dev-external` (macOS External SSD Guard)

Protect your internal Mac SSD from temporary build/render bloat and fail closed if the external drive is disconnected:

```bash
dev-external --init /Volumes/YourExternalSSD
dev-external --status

# Prefix heavy commands:
dev-external npm run build
dev-external colab sessions
```

### 3. Initialize the `.ai/` Cross-Device Bus (`ai-link`)

Requires Google Drive for Desktop (or set `AI_HUB_DIR=/path/to/cloud/AI-Projects` for iCloud / Dropbox / Syncthing):

```bash
# 1. Create _REGISTRY.md, _GLOBAL_INBOX.md, and _skills/ in your cloud hub
ai-link --init-hub

# 2. Link any local Git repository (adds `.ai/` to .git/info/exclude so .gitignore stays clean)
cd /path/to/your-repo
ai-link

# 3. Bidirectionally sync plain-text skills & generate _skills/_INDEX.md
ai-link --sync-skills
```

To customize which skill directories are indexed or categorized, copy `templates/skills.example.json` to `~/.config/ai-link/skills.json`.

### 4. Set Up Zero-Leak Colab L4 Offloading

Install Google's official CLI via `uv`:

```bash
uv tool install git+https://github.com/googlecolab/google-colab-cli
colab sessions   # completes OAuth once
colab usage      # check compute unit balance
```

Use the Zero-Leak wrapper so crashed or interrupted runs still call `colab stop` and confirm `colab sessions` is empty:

```bash
~/.agents/skills/colab-gpu-offload/scripts/colab_zero_leak.sh \
  my-worker ./remote_job.py /content/scratch/output.mp4 ./output.mp4
```

## Verification

Run the included offline integration tests (creates temporary directories only, zero cloud/network mutations):

```bash
bash tests/test_ai_ultra_kit.sh
```

## License

[MIT](LICENSE)
