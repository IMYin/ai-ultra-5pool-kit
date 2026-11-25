# Agent Instructions (`fictional-webapp` Example)

> This example demonstrates how an ordinary full-stack project uses `ai-ultra-5pool-kit` to coordinate **Cloud AI Studio -> `.ai/` Symlink Bus -> Local Coding Agent + Colab L4 GPU**.

## Build & Test
```bash
pnpm test
```

## Cloud Context Sync (`.ai/`)
This repository shares persistent context with cloud AI sessions through `.ai/`:
1. **Read on start**: Read `.ai/CONTEXT.md`, `.ai/STATUS.md`, and `.ai/INBOX.md` before planning or coding.
2. **Consume inbox**: Execute pending tasks/specs in `.ai/INBOX.md` and `.ai/specs/HANDOFF-FOR-AGENT.md`; offload GPU-heavy jobs via `colab_zero_leak.sh`.
3. **Write back on finish**: Update `.ai/STATUS.md` with verified results and clear completed `.ai/INBOX.md` entries.
