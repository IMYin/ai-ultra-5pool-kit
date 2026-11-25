---
name: colab-gpu-offload
description: Offload GPU-heavy AI inference, batch frame rendering, TTS/Whisper pipelines, and high-bandwidth dataset tasks to Google Colab L4 GPUs via google-colab-cli with strict zero-leak VM termination and stdout limits.
---

# Colab GPU Offload (`google-colab-cli`)

Use `google-colab-cli` (`colab`) to offload heavy GPU / CPU / high-bandwidth jobs from a local workstation to remote **NVIDIA L4 (24GB VRAM)** instances without spinning up local fans or wasting compute units.

## 1. Ideal Tasks for Offloading

1. **Audio & Voice Pipelines**: Batch TTS inference, Whisper alignment verification, stem separation.
2. **Headless Video & Frame Rendering**: Parallel headless browser rendering, batch GIF/video encoding.
3. **Batch Dataset & High-Bandwidth Jobs**: Pulling large remote archives, ML fine-tuning/evaluation, Parquet crunching.

## 2. Five Anti-Waste & Zero-Leak Iron Laws

1. **Default to L4 GPU (`--gpu L4`)**: 24GB VRAM gives the best performance per Compute Unit compared to T4 (small VRAM) or A100 (high CU drain). Pass `--high-mem` when switching to `--gpu T4`, `--gpu A100`, or CPU runtimes.
2. **Prefer `colab run` for One-Shot Jobs**:
   ```bash
   colab run --gpu L4 --timeout 0 job.py [args...]
   ```
   `colab run` automatically tears down the VM upon script exit (do not pass `--keep`).
3. **Use `/content/scratch/` for Multi-Step Jobs (Never Heavy I/O on Drive FUSE)**:
   - Launch and mount:
     ```bash
     colab new -s worker --gpu L4
     colab drivemount -s worker
     ```
   - Never run thousands of small frame/chunk writes directly on `/content/drive`. Compute everything on `/content/scratch/` first, package final artifacts (`.mp4` / `.tar.gz` / `.json`), then download via `colab download` or copy to Drive with `rsync`.
4. **Enforce Zero-Leak Termination (`trap cleanup EXIT`)**:
   - Every `colab new` workflow must wrap cleanup in `trap`:
     ```bash
     cleanup() {
       colab stop -s "$SESSION" || true
       colab sessions || true
     }
     trap cleanup EXIT
     ```
   - Always confirm `colab sessions` prints **zero active instances** when finished.
5. **Prevent Local Context Window Explosion**:
   - Remote scripts must never print >50 lines of tables, raw logs, or Base64 strings to stdout. Write detailed outputs to `/content/scratch/`, print only concise metrics, and inspect files after download.

## 3. Quick Reference

```bash
colab usage
colab sessions
colab run --gpu L4 --timeout 0 path/to/job.py
```

Or use the bundled Zero-Leak runner:
```bash
./scripts/colab_zero_leak.sh --drive my-job /path/to/remote_job.py /content/scratch/out.bin ./out.bin
```
