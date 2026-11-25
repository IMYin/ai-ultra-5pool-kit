---
name: colab-gpu-offload
description: Offload GPU-heavy AI inference, batch frame rendering, TTS voice cloning, and high-bandwidth dataset tasks to Google Colab L4 GPUs via google-colab-cli with strict zero-leak VM termination and stdout limits.
---

# Colab GPU Offload (`google-colab-cli`)

Use `google-colab-cli` (`colab`) to offload heavy GPU / CPU / high-bandwidth jobs from a local workstation to remote **NVIDIA L4 (24GB VRAM)** instances without spinning up local fans or wasting subscription compute units.

## 1. Ideal Tasks for Offloading

1. **Audio & Voice Pipelines**: Batch TTS inference (`F5-TTS`, etc.), Whisper alignment verification, stem separation.
2. **Headless Video & Frame Rendering**: Parallel headless Chrome rendering (`Remotion`, `Puppeteer`), batch supersampled GIF encoding.
3. **Batch Dataset & High-Bandwidth Jobs**: Pulling remote archives, building large Parquet grids, ML fine-tuning/evaluation.

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
   - Never run thousands of small frame/chunk writes directly on `/content/drive`. Compute everything on `/content/scratch/` local NVMe SSD first, package final artifacts (`.mp4` / `.tar.gz` / `.wav`), then copy back with `colab download` or `rsync`.
4. **Enforce Zero-Leak Termination (`trap cleanup EXIT`)**:
   - Every `colab new` workflow must wrap cleanup in `trap`:
     ```bash
     cleanup() {
       colab stop -s "$SESSION" || true
       colab sessions || true
     }
     trap cleanup EXIT
     ```
   - Always confirm `colab sessions` prints **zero active instances** when done.
5. **Prevent Local Context Window Explosion**:
   - Remote scripts must never print >50 lines of tables, raw logs, or Base64 strings to stdout. Write detailed reports to files in `/content/scratch/`, print only concise metrics (paths, durations, pass/fail), and download files locally if inspection is needed.

## 3. Quick Reference

```bash
colab usage
colab sessions
colab run --gpu L4 --timeout 0 path/to/job.py
```

Or use the bundled Zero-Leak runner:
```bash
./scripts/colab_zero_leak.sh my-job /path/to/remote_job.py /content/scratch/out.mp4 ./out.mp4
```
