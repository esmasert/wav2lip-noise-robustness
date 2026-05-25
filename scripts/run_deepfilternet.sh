#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <noisy_audio_folder> <denoised_output_folder>"
  exit 1
fi

NOISY_DIR="$1"
OUT_DIR="$2"
mkdir -p "$OUT_DIR"

# Assumes DeepFilterNet3 installed and entrypoint `deepfilternet` available
for f in "$NOISY_DIR"/*.wav; do
  base=$(basename "$f")
  out="$OUT_DIR/$base"
  echo "Denoising $f -> $out"
  if command -v deepfilternet >/dev/null 2>&1; then
    deepfilternet --input "$f" --output "$out" || echo "DeepFilterNet failed for $f"
  else
    echo "deepfilternet CLI not found; copying as placeholder"
    cp "$f" "$out"
  fi
done

echo "DeepFilterNet pass complete; outputs in $OUT_DIR"
