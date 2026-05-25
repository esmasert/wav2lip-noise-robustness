#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <audio_folder> <output_folder> <input_face_video>"
  exit 1
fi

AUDIO_DIR="$1"
OUT_DIR="$2"
FACE_VIDEO="$3"
mkdir -p "$OUT_DIR"

# WAV2LIP_PATH should point to local Wav2Lip clone
: "${WAV2LIP_PATH:=Wav2Lip-master}"

for audio in "$AUDIO_DIR"/*.wav; do
  base=$(basename "$audio" .wav)
  out="$OUT_DIR/${base}_wav2lip.mp4"
  echo "Running Wav2Lip for $audio -> $out"
  python3 "$WAV2LIP_PATH"/inference.py --face "$FACE_VIDEO" --audio "$audio" --outfile "$out" || echo "Wav2Lip failed for $audio"
done

echo "Wav2Lip runs complete; outputs in $OUT_DIR"
