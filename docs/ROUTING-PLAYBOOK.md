# 5-Pool Workload Routing Playbook

English | [简体中文](ROUTING-PLAYBOOK.zh-CN.md)

Rules and decision trees for deciding which compute pool handles each workload—so your local coding agent stays focused on high-leverage code edits while cloud GPUs and daily-reset web UIs absorb the rest.

---

## 1. Workload Dispatch Tree

```text
Incoming Task
  ├── Heavy reading (>50k tokens), spec synthesis, long drafts, audio/video QA?
  │     └── Route to Pool 3 (AI Studio Web UI) or Pool 2 (Web Research)
  │           Write deliverables to .ai/specs/<task>/ + .ai/INBOX.md + HANDOFF-FOR-AGENT.md
  │
  ├── High VRAM inference, batch rendering, dataset crunching, high-bandwidth fetch?
  │     └── Route to Pool 4 (Colab L4 via google-colab-cli)
  │           Compute in /content/scratch/, <=50-line stdout, enforce Zero-Leak cleanup
  │
  ├── Elastic high-concurrency API burst or lightweight cloud microservice tests?
  │     └── Route to Pool 5 (Cloud Credits / Elastic API)
  │           Enable Billing Budget Alerts; keep keys in local env vars only
  │
  └── Code edits, refactoring, typechecks, unit tests, git operations?
        └── Route to Pool 1 (Local Coding Agent)
              Read .ai/CONTEXT.md + STATUS.md + INBOX.md first; update STATUS.md on finish
```

---

## 2. Five Iron Laws for `.ai/` Cross-Device Sync

1. **Plain text only (`.md` / `.json`)**: Never create proprietary online doc shortcuts inside `AI-Projects/`. Every file must be readable by both browser file pickers and local CLI agents.
2. **Zero Git pollution**: `ai-link` appends `.ai` to `.git/info/exclude`, never touching the shared `.gitignore` or tracking personal scratch notes in Git history.
3. **Cloud drafts specs; local agent owns code & tests**: Cloud web UIs may generate JSON specs, schemas, and `HANDOFF-FOR-AGENT.md`, but all repository edits must still pass local typechecks and tests.
4. **Consume & clear `INBOX.md`**: Once local work completes, summarize verified outputs in `.ai/STATUS.md` and clear finished items from `.ai/INBOX.md` to avoid duplicate execution in future sessions.
5. **Protect agent context windows**: Save large artifacts and logs to `.ai/specs/` or temporary files, inspect slices or concise metrics only, and never paste raw dumps or Base64 blobs into chat.

---

## 3. Colab L4 Zero-Leak Checklist

- **One-shot scripts**: Always use `colab run --gpu L4 --timeout 0 job.py` (automatically terminates VM on exit; never pass `--keep`).
- **Multi-step sessions**:
  1. `colab new -s <name> --gpu L4`
  2. `colab drivemount -s <name>` (only if Drive access is needed)
  3. **Run heavy scratch I/O in `/content/scratch/`** (avoid random small-file writes directly on `/content/drive` FUSE)
  4. Download artifacts, then immediately run `colab stop -s <name> && colab sessions`
- **Acceptance check**: Every workflow must end with `colab sessions` showing **no active sessions**.
