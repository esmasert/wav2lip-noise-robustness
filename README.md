# Wav2Lip Noise Robustness Experiment

This repository investigates how noisy audio conditions affect Wav2Lip-generated lip synchronisation quality, using SyncNet evaluation, perceptual inspection, and DeepFilterNet3 preprocessing experiments.

## Motivation
Evaluate how background noise and denoising (DeepFilterNet3) affect Wav2Lip generated video lip-sync quality, measured by SyncNet scores and perceptual inspection.

## Experimental setup
- Input: a single face video and multiple audio conditions (clean, noisy, denoised)
- Pipelines: Wav2Lip for lip synthesis, SyncNet for objective scoring, DeepFilterNet3 for denoising
- Scripts: see `scripts/` for reproducible steps

## Noise types used
- background_people_noise
- cat_meow
- guitar_music
- piano_music
- violin_music

## Wav2Lip and SyncNet pipeline
- Run `scripts/run_wav2lip.sh` to generate videos for audio conditions
- Run `scripts/run_syncnet.sh` to score videos; logs placed in `results/syncnet_logs/`

## DeepFilterNet preprocessing pipeline
- Run `scripts/run_deepfilternet.sh` to denoise noisy audio files and save into `audio_samples/`

## Results and summaries
Full raw SyncNet logs are kept at `results/syncnet_logs/all_syncnet_results.txt`.

Structured result tables are available in `results/tables/`:

- `results/tables/all_results_summary.csv`
- `results/tables/all_results_summary.md`

Below is a concise, cleaned summary of the main SyncNet metrics from the experiments:

| Experiment | Category | AV Offset | Min Dist | Confidence |
|---|---|---:|---:|---:|
| Baseline original video | Original video | 2 | 8.159 | 5.387 |
| Baseline Wav2Lip with original audio | Original audio → Wav2Lip | -2 | 7.463 | 7.159 |
| Dave + background people noise | Noisy Wav2Lip, Dave audio | -2 | 8.873 | 5.184 |
| Dave + cat meow | Noisy Wav2Lip, Dave audio | -2 | 9.543 | 5.236 |
| Dave + guitar music | Noisy Wav2Lip, Dave audio | -2 | 8.443 | 5.583 |
| Dave + piano music | Noisy Wav2Lip, Dave audio | -2 | 8.339 | 5.778 |
| Dave + violin music | Noisy Wav2Lip, Dave audio | -2 | 7.972 | 6.498 |
| Original + background people noise | Noisy Wav2Lip, original audio | -2 | 8.656 | 4.592 |
| Original + cat meow | Noisy Wav2Lip, original audio | -2 | 9.083 | 5.081 |
| Original + guitar music | Noisy Wav2Lip, original audio | -2 | 8.445 | 5.367 |
| Original + piano music | Noisy Wav2Lip, original audio | -2 | 8.224 | 5.248 |
| Original + violin music | Noisy Wav2Lip, original audio | -2 | 8.146 | 5.693 |
| Original + background people noise + DeepFilterNet3 | Denoised Wav2Lip | -2 | 7.682 | 6.349 |
| Original + cat meow + DeepFilterNet3 | Denoised Wav2Lip | -2 | 7.965 | 6.622 |
| Original + guitar music + DeepFilterNet3 | Denoised Wav2Lip | -2 | 7.581 | 6.646 |
| Original + piano music + DeepFilterNet3 | Denoised Wav2Lip | -2 | 7.427 | 6.719 |
| Original + violin music + DeepFilterNet3 | Denoised Wav2Lip | -2 | 7.461 | 6.943 |

## Key Findings

- **Wav2Lip generated videos achieved higher SyncNet confidence than the original video itself when using clean audio**
  - Original video confidence: **5.387**
  - Wav2Lip with clean audio: **7.159**

- **This behaviour is expected because Wav2Lip is trained using a SyncNet-style discriminator/loss**, meaning the model is partially optimised for SyncNet-like audio-visual alignment objectives.

- **Higher SyncNet scores did not always correspond to better perceptual visual quality**
  - Some noisy videos still received moderate SyncNet confidence scores despite visibly unnatural mouth motion.

- **Visual inspection showed that Wav2Lip can still react to background noise and non-speech audio**
  - Background speech, music, and cat meow sounds sometimes influenced generated mouth movement.

- **SyncNet alone is not sufficient to evaluate perceptual lip-sync quality**
  - SyncNet measures audio-visual synchronisation, but not visual realism, mouth naturalness, identity preservation, or whether the mouth is responding to the correct speaker.

- **Additional visual quality evaluation is needed**
  - Human inspection or extra perceptual metrics are required alongside SyncNet for a more complete evaluation.

- **Background speech noise was the most harmful noise condition**
  - Confidence dropped from **7.159 → 4.592**
  - Competing speech-like patterns strongly affected generated mouth movement.

- **DeepFilterNet3 preprocessing consistently improved noisy Wav2Lip outputs**
  - Background people noise improved from **4.592 → 6.349**
  - All denoised conditions showed higher SyncNet confidence compared with their noisy counterparts.

- **The experiments suggest that mel spectrogram conditioning is a major robustness bottleneck**
  - Mel spectrograms encode acoustic energy but do not explicitly separate target speech, background speech, music, or non-speech acoustic events.

- **The results indicate that robust audio-driven lip synchronisation likely requires speech-aware conditioning representations**
  - Future directions include HuBERT, WavLM, source separation, speech enhancement, and perceptual visual evaluation metrics.

## Additional SyncNet Behaviour Analysis

We added a focused set of SyncNet behaviour experiments investigating manual temporal shifts and speaker overlap conditions. The experiments probe how SyncNet reacts to controlled audio lead/lag, overlapping speakers, and loud competing speech. Key takeaways are summarised below and a compact results table is included for reference.

**Summary of new findings:**
- **Manual temporal shifts** (audio delayed/advanced by 200 ms) caused SyncNet to change its predicted AV offset in the expected direction and magnitude.
- **Noise and short overlap conditions** primarily reduced SyncNet confidence scores rather than producing large AV offset errors.
- **Full overlap and loud competing speaker** scenarios produced substantial confidence drops, indicating reduced SyncNet reliability under speaker-confusion conditions.
- **Wav2Lip outputs** continued to show very high SyncNet confidence because the model is trained with a SyncNet-style objective.

**Selected SyncNet behaviour results** (from `results/syncnet_analysis/tables/syncnet_behaviour_results.md`):

| experiment_name | video_file | av_offset | min_dist | confidence | status |
|---|---|---|---:|---:|---|
| example | data/example.avi | 3 | 6.556 | 8.353 | OK |
| test_10sec_syncnet | data/test_10sec_syncnet.avi | NA | NA | NA | PARSE_FAILED |
| test10_pipeline | data/test10_pipeline.avi | 2 | 8.164 | 5.420 | OK |
| test98_audio_delay_200ms | data/test98_audio_delay_200ms.avi | NA | NA | NA | SYNCNET_FAILED |
| test98_pipeline | data/test98_pipeline.avi | 2 | 8.159 | 5.387 | OK |
| test98_audio_advance_200ms | data/test98_audio_advance_200ms.mov | 7 | 8.514 | 5.109 | OK |
| test98_audio_delay_200ms | data/test98_audio_delay_200ms.mov | -3 | 8.357 | 5.219 | OK |
| test98_full_overlap | data/test98_full_overlap.mov | 2 | 12.215 | 1.642 | OK |
| test98_noise | data/test98_noise.mov | 2 | 8.098 | 5.000 | OK |
| test98_other_speaker_overlap_loud | data/test98_other_speaker_overlap_loud.mov | 2 | 10.740 | 3.157 | OK |
| test98_other_speaker_overlap | data/test98_other_speaker_overlap.mov | 2 | 9.730 | 3.782 | OK |
| test98_overlap | data/test98_overlap.mov | 1 | 9.523 | 3.943 | OK |
| result_dave_wav2lip | data/result_dave_wav2lip.mp4 | -2 | 5.761 | 9.543 | OK |
| test_10sec | data/test_10sec.mp4 | 0 | 7.432 | 6.662 | OK |

For full, raw results and the original result file see: [results/syncnet_analysis/tables/syncnet_behaviour_results.md](results/syncnet_analysis/tables/syncnet_behaviour_results.md)

Video examples for these tests are stored (or expected) under `results/syncnet_analysis/videos/` with subfolders:

- `audio_delay/`
- `audio_advance/`
- `overlap/`
- `competing_speaker_overlap/`
- `full_overlap/`

Place the tested example videos in the appropriate subfolders for quick inspection; placeholder READMEs are included in each directory describing expected filenames.

## Limitations
- Checkpoints and large video files are excluded from the repo.
- Reproducibility requires external Wav2Lip and SyncNet repositories and model files.

## Future work
- Evaluate HuBERT/WavLM conditioning.
- Integrate alternative denoisers and compare effect on SyncNet.

## External repositories
This project references external code: Wav2Lip and SyncNet. Install them separately and place model checkpoints as described below.

## Checkpoints (do not commit)
- wav2lip_gan.pth
- syncnet_v2.model
- s3fd.pth

## How to run (example)
Set `WAV2LIP_PATH` and `SYNCNET_PATH` environment variables to point to local clones. Then:

```bash
bash scripts/generate_noisy_audio.sh audio_samples/original_audio.wav
bash scripts/run_wav2lip.sh audio_samples/ output_videos/ input_face.mp4
bash scripts/run_deepfilternet.sh audio_samples/ audio_samples/denoised/
bash scripts/run_wav2lip.sh audio_samples/denoised/ output_videos_denoised/ input_face.mp4
bash scripts/run_syncnet.sh output_videos/ results/syncnet_logs/
```

See `scripts/` for detailed usage.

## External repositories

Wav2Lip: https://github.com/Rudrabha/Wav2Lip

SyncNet: https://github.com/joonson/syncnet_python

DeepFilterNet: https://github.com/Rikorose/DeepFilterNet

## Disclaimer

This repository does not reimplement Wav2Lip or SyncNet. It documents experiments analysing robustness of audio-driven lip synchronisation under noisy audio conditions.

