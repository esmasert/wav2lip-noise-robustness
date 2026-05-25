#!/bin/bash

set -e

# Usage:
#   SYNCNET_DIR=/path/to/syncnet_python-master \
#   WAV2LIP_DIR=/path/to/Wav2Lip-master \
#   bash scripts/evaluate_all_syncnet.sh
#
# If not provided, defaults assume sibling folders next to this repository.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_DIR="$(dirname "$REPO_DIR")"

SYNCNET_DIR="${SYNCNET_DIR:-$BASE_DIR/syncnet_python-master}"
WAV2LIP_DIR="${WAV2LIP_DIR:-$BASE_DIR/Wav2Lip-master}"

LOG_FILE="$REPO_DIR/results/syncnet_logs/all_syncnet_results.txt"
CSV_FILE="$REPO_DIR/results/tables/all_results_summary.csv"
MD_FILE="$REPO_DIR/results/tables/all_results_summary.md"

mkdir -p "$REPO_DIR/results/syncnet_logs"
mkdir -p "$REPO_DIR/results/tables"

echo "===== ALL SYNCNET RESULTS =====" > "$LOG_FILE"
echo "experiment_name,source_video,category,av_offset,min_dist,confidence" > "$CSV_FILE"

cd "$SYNCNET_DIR"

score_video () {
  local video="$1"
  local category="$2"
  local name="$3"

  echo "Scoring: $name"

  rm -rf \
    "data/work/pytmp/$name" \
    "data/work/pycrop/$name" \
    "data/work/pywork/$name" \
    "data/work/pyavi/$name" \
    "data/work/pyframes/$name"

  {
    echo ""
    echo "===== $name ====="
    echo "CATEGORY: $category"
    echo "SOURCE: $video"
    echo ""
  } >> "$LOG_FILE"

  python run_pipeline.py \
    --videofile "$video" \
    --reference "$name" \
    --data_dir data/work >> "$LOG_FILE" 2>&1

  python run_syncnet.py \
    --videofile "$video" \
    --reference "$name" \
    --data_dir data/work > "/tmp/${name}_syncnet.txt" 2>&1

  cat "/tmp/${name}_syncnet.txt" >> "$LOG_FILE"

  av_offset=$(grep "AV offset" "/tmp/${name}_syncnet.txt" | awk '{print $NF}')
  min_dist=$(grep "Min dist" "/tmp/${name}_syncnet.txt" | awk '{print $NF}')
  confidence=$(grep "Confidence" "/tmp/${name}_syncnet.txt" | awk '{print $NF}')

  relative_video="${video/#$WAV2LIP_DIR\//external/Wav2Lip-master/}"

  echo "$name,$relative_video,$category,$av_offset,$min_dist,$confidence" >> "$CSV_FILE"
}

score_video "$WAV2LIP_DIR/test98_pipeline.avi" \
  "baseline_original_video" \
  "baseline_original_video"

score_video "$WAV2LIP_DIR/results_original_audio_wav2lip.mp4" \
  "baseline_wav2lip_original_audio" \
  "baseline_wav2lip_original_audio"

for video in "$WAV2LIP_DIR/results_noise/"*.mp4; do
  base=$(basename "$video" .mp4)
  score_video "$video" "noisy_wav2lip_dave_audio" "$base"
done

for video in "$WAV2LIP_DIR/results_original_noise/"*.mp4; do
  base=$(basename "$video" .mp4)
  score_video "$video" "noisy_wav2lip_original_audio" "$base"
done

for video in "$WAV2LIP_DIR/denoise_experiment/wav2lip_results/"*.mp4; do
  base=$(basename "$video" .mp4)
  score_video "$video" "denoised_wav2lip_original_audio" "$base"
done

python - <<PY
import csv

csv_file = "$CSV_FILE"
md_file = "$MD_FILE"

with open(csv_file, newline="") as f:
    rows = list(csv.reader(f))

headers = rows[0]
data = rows[1:]

def fmt_row(row):
    return "| " + " | ".join(row) + " |"

with open(md_file, "w") as f:
    f.write(fmt_row(headers) + "\n")
    f.write("|" + "|".join(["---"] * len(headers)) + "|\n")
    for row in data:
        f.write(fmt_row(row) + "\n")

print(f"Markdown table saved to: {md_file}")
PY

echo "Done."
echo "Log: $LOG_FILE"
echo "CSV: $CSV_FILE"
echo "Markdown: $MD_FILE"
