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

## Additional SyncNet Behaviour Experiments

Additional controlled SyncNet experiments were performed to analyse how SyncNet reacts under different temporal and acoustic conditions.

The tested conditions included:
- audio delay (+200 ms)
- audio advance (-200 ms)
- overlapping speakers
- loud competing speaker overlap
- noisy audio
- Wav2Lip generated videos

Key observations:
- Artificial audio delay and advance changed the predicted AV offset as expected.
- Competing speaker overlap reduced SyncNet confidence significantly.
- Full overlap conditions produced very low confidence despite temporal alignment.
- Wav2Lip-generated videos achieved very high SyncNet confidence scores.
- Some noisy or perceptually unnatural videos still received moderate SyncNet scores.

Results are available in:
- `results/syncnet_analysis/tables/syncnet_behaviour_results.md`
- `results/syncnet_analysis/videos/`

## Results and summaries
Full raw SyncNet logs are kept at `results/syncnet_logs/all_syncnet_results.txt`.

Structured result tables are available in `results/tables/`:

- `results/tables/all_results_summary.csv`
- `results/tables/all_results_summary.md`

Below is a concise, cleaned summary of the main SyncNet metrics from the experiments:

## Main Wav2Lip Noise Robustness Results

| Experiment | Condition | AV Offset | Min Dist | Confidence |
|---|---|---:|---:|---:|
| Original video | Clean original video | 2 | 8.159 | 5.387 |
| Wav2Lip clean audio | Clean original audio → Wav2Lip | -2 | 7.463 | 7.159 |
| Background speech noise | Noisy original audio → Wav2Lip | -2 | 8.656 | 4.592 |
| Cat meow | Noisy original audio → Wav2Lip | -2 | 9.083 | 5.081 |
| Guitar music | Noisy original audio → Wav2Lip | -2 | 8.445 | 5.367 |
| Piano music | Noisy original audio → Wav2Lip | -2 | 8.224 | 5.248 |
| Violin music | Noisy original audio → Wav2Lip | -2 | 8.146 | 5.693 |
| Background speech + DeepFilterNet3 | Denoised audio → Wav2Lip | -2 | 7.682 | 6.349 |
| Cat meow + DeepFilterNet3 | Denoised audio → Wav2Lip | -2 | 7.965 | 6.622 |
| Guitar music + DeepFilterNet3 | Denoised audio → Wav2Lip | -2 | 7.581 | 6.646 |
| Piano music + DeepFilterNet3 | Denoised audio → Wav2Lip | -2 | 7.427 | 6.719 |
| Violin music + DeepFilterNet3 | Denoised audio → Wav2Lip | -2 | 7.461 | 6.943 |

## Additional SyncNet Behaviour Results

| Experiment | Condition | AV Offset | Min Dist | Confidence | Interpretation |
|---|---|---:|---:|---:|---|
| Original video | Clean original video | 2 | 8.159 | 5.387 | Baseline SyncNet behaviour |
| Audio advanced 200 ms | Manual temporal shift | 7 | 8.514 | 5.109 | SyncNet offset changed under artificial misalignment |
| Audio delayed 200 ms | Manual temporal shift | -3 | 8.357 | 5.219 | SyncNet offset changed in the opposite direction |
| Normal noise | Added background noise | 2 | 8.098 | 5.000 | Noise reduced confidence slightly without large offset change |
| Short overlap | Overlapping audio | 1 | 9.523 | 3.943 | Overlap mainly reduced confidence |
| Other speaker overlap | Competing speaker | 2 | 9.730 | 3.782 | Speaker interference reduced confidence |
| Loud other speaker overlap | Loud competing speaker | 2 | 10.740 | 3.157 | Strong competing speech further reduced confidence |
| Full overlap | Full competing overlap | 2 | 12.215 | 1.642 | Severe overlap caused very low confidence |
| Wav2Lip output with Dave audio | Wav2Lip generated video | -2 | 5.761 | 9.543 | Very high confidence, consistent with SyncNet-style training objective |

These additional SyncNet behaviour experiments suggest that artificial temporal shifts are reflected in the predicted AV offset, while noisy or overlapping audio mainly reduces SyncNet confidence. This supports the interpretation that SyncNet offset and confidence should be analysed together, and that SyncNet alone is not sufficient to judge perceptual lip-sync quality.

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

## Test Media and Audio Sources

The original input video clip was obtained from publicly available online video content and cropped to a short segment for research experimentation only.

Original video source:  
https://www.youtube.com/watch?v=7ARBJQn6QkM&t=1175s

The additional reference audio sample used in some experiments was obtained from the NeuTTS project by Neuphonic:

`dave.wav`:  
https://github.com/neuphonic/neutts/blob/main/samples/dave.wav

All media assets are used strictly for research and experimental evaluation purposes. If requested by the original rights holders, the relevant media files will be removed.
