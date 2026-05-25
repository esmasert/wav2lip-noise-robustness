#!/usr/bin/env bash
set -euo pipefail

# Simple orchestrator: arguments can be extended as needed
CLEAN_AUDIO="${1:-audio_samples/original_audio.wav}"
FACE_VIDEO="${2:-input_face.mp4}"
WORK_DIR="${3:-.}"

# 1) Generate noisy audio
bash scripts/generate_noisy_audio.sh "$CLEAN_AUDIO" audio_samples

# 2) Run Wav2Lip on noisy audio
bash scripts/run_wav2lip.sh audio_samples results/videos/noisy_wav2lip "$FACE_VIDEO"

# 3) Denoise using DeepFilterNet
bash scripts/run_deepfilternet.sh audio_samples audio_samples/denoised

# 4) Run Wav2Lip on denoised audio
bash scripts/run_wav2lip.sh audio_samples/denoised results/videos/denoised_wav2lip "$FACE_VIDEO"

# 5) Run SyncNet scoring
bash scripts/run_syncnet.sh results/videos/noisy_wav2lip results/syncnet_logs
bash scripts/run_syncnet.sh results/videos/denoised_wav2lip results/syncnet_logs

# 6) (Optional) Extract logs/tables — user can parse logs into CSVs

echo "Full pipeline executed (placeholders used where tools not installed)."
