#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <clean_audio.wav> [output_dir]"
  exit 1
fi

CLEAN_AUDIO="$1"
OUT_DIR="${2:-audio_samples}"
mkdir -p "$OUT_DIR"

NOISES=("background_people_noise.wav" "cat_meow.wav" "guitar_music.wav" "piano_music.wav" "violin_music.wav")

for noise in "${NOISES[@]}"; do
  NOISE_PATH="audio_samples/$noise"
  OUT_NAME="$OUT_DIR/$(basename "$CLEAN_AUDIO" .wav)_${noise}"
  # Example using sox to mix; adjust SNR as needed.
  if command -v sox >/dev/null 2>&1; then
    sox -m -v 1 "$CLEAN_AUDIO" -v 1 "$NOISE_PATH" "$OUT_NAME"
  else
    echo "sox not found; copying clean audio as placeholder for $OUT_NAME"
    cp "$CLEAN_AUDIO" "$OUT_NAME"
  fi
done

echo "Generated noisy audio files in $OUT_DIR"
