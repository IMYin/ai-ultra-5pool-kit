# fictional-webapp - Project Context (CONTEXT)

## 1. Core Positioning & Goal
- A fictional multi-language documentation search & audio-transcript indexing web app (Next.js + Python batch indexer).

## 2. Tech Stack & Layout
- `apps/web/`: Next.js TypeScript frontend (`pnpm --filter web typecheck && pnpm --filter web test`)
- `scripts/batch_embed.py`: Offline embedding batch job (offload heavy GPU runs to Colab L4 via `colab_zero_leak.sh`)

## 3. Architecture Constraints
- Keep `.ai/` synced files in plain Markdown/JSON only.
- Never commit API keys or `.ai/` to Git (`.ai` is ignored via `.git/info/exclude`).
