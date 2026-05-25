#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <video_folder> <output_log_dir>"
  exit 1
fi

VIDEO_DIR="$1"
OUT_DIR="$2"
mkdir -p "$OUT_DIR"

: "${SYNCNET_PATH:=syncnet_python-master}"

for vid in "$VIDEO_DIR"/*.mp4; do
  base=$(basename "$vid" .mp4)
  log="$OUT_DIR/${base}_syncnet_scores.txt"
  echo "Scoring $vid -> $log"
  python3 "$SYNCNET_PATH"/run_pipeline.py --video "$vid" > "$log" 2>&1 || echo "SyncNet failed for $vid"
done

echo "SyncNet scoring complete; logs in $OUT_DIR"
