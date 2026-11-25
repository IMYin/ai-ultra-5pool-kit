#!/usr/bin/env python3
"""Sample remote script executed on Colab L4 inside /content/scratch/ (anti-waste demo)."""
import json
import os
import subprocess
import time

OUT_PATH = "/content/scratch/index_summary.json"


def main() -> None:
    os.makedirs("/content/scratch", exist_ok=True)
    t0 = time.time()
    gpu = subprocess.run(
        "nvidia-smi --query-gpu=name,memory.total --format=csv,noheader || echo CPU",
        shell=True,
        text=True,
        capture_output=True,
    ).stdout.strip()

    # Heavy work happens strictly inside /content/scratch/ local NVMe, never Drive FUSE
    summary = {
        "gpu": gpu,
        "processed_docs": 10240,
        "elapsed_sec": round(time.time() - t0, 3),
        "status": "ok",
    }
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)

    # Print <=50 lines summary to protect local agent context window
    print(f"OK | gpu={gpu} | docs={summary['processed_docs']} -> {OUT_PATH}")


if __name__ == "__main__":
    main()
