# HANDOFF FOR LOCAL CODING AGENT

> Generated in Pool 3 (AI Studio Web UI). Local Agent should execute in Pool 1 + Pool 4 without re-running long text synthesis locally.

## Goal
Offload heavy batch index computation from the local workstation to Colab L4 GPU, pull the compact JSON summary back locally, and verify the web app typechecks cleanly.

## Steps for Local Agent
1. Run the Zero-Leak Colab wrapper:
   ```bash
   ~/.agents/skills/colab-gpu-offload/scripts/colab_zero_leak.sh \
     webapp-embed .ai/specs/sample_colab_l4_job.py /content/scratch/index_summary.json ./artifacts/index_summary.json
   ```
2. Verify `colab sessions` reports zero active sessions.
3. Run `pnpm --filter web typecheck && pnpm --filter web test`.
4. Update `.ai/STATUS.md` with output metrics and clear `.ai/INBOX.md`.
