---
name: ai-cloud-sync
description: Cross-device .ai/ shared-memory workflow connecting local coding agents (Claude Code, Cursor, Codex, Antigravity, Windsurf) with browser/mobile cloud AI workspaces via plain-text CONTEXT.md, STATUS.md, INBOX.md, and specs/.
---

# Cloud Context Sync (`.ai/` Protocol)

Maintain seamless handoff between high-context browser/mobile models (e.g., Google AI Studio Web UI, Gemini Web/App) and local coding agents without copy-pasting prompts or polluting Git history.

## Directory Contract

Every linked project exposes a `.ai/` symlink at its repository root (ignored locally via `.git/info/exclude`):

```text
.ai/
├── CONTEXT.md    # Architecture truth: stack, commands, data models, non-negotiables
├── STATUS.md     # Live status: recent completions, blockers, next TODOs
├── INBOX.md      # Incoming task queue dropped from cloud/mobile AI sessions
└── specs/        # Larger JSON payloads, rendered drafts, or HANDOFF-FOR-AGENT.md
```

## Session Lifecycle

1. **Before coding**: Read `.ai/CONTEXT.md`, `.ai/STATUS.md`, and `.ai/INBOX.md`.
2. **If `.ai/INBOX.md` has open items**: Treat them (and any referenced file in `.ai/specs/`) as active requirements.
3. **Before finishing**:
   - Archive completed `INBOX.md` tasks into `.ai/STATUS.md` and clear finished inbox entries.
   - Update `.ai/STATUS.md` with exact tests run, blockers, and next steps.
   - Keep every file in `.ai/` as plain-text `.md` or `.json` (never proprietary binary/online docs).
