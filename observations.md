# Observations

This document summarises the qualitative and quantitative observations from the Wav2Lip noise robustness experiments.

## Experiment Overview

The goal of this experiment was to evaluate how Wav2Lip behaves when the conditioning audio contains different types of interference.

The tested interference types were:

- background people noise
- cat meow
- guitar music
- piano music
- violin music

The main pipeline was:

```text
Original audio
→ add noise
→ Wav2Lip generation
→ SyncNet evaluation
→ visual inspection
```

A second pipeline added DeepFilterNet3 preprocessing:

```text
Noisy audio
→ DeepFilterNet3
→ Wav2Lip generation
→ SyncNet evaluation
→ visual inspection
```

## Baseline Observations

The original video achieved:

- AV offset: 2
- Min dist: 8.159
- Confidence: 5.387

When Wav2Lip was run using the original clean audio, the SyncNet confidence increased:

- AV offset: -2
- Min dist: 7.463
- Confidence: 7.159

This suggests that Wav2Lip can produce mouth motion that is more strongly aligned according to SyncNet than the original video itself.

This is understandable because Wav2Lip was trained with a SyncNet-style expert discriminator/loss, meaning the generated mouth motion is explicitly encouraged to optimise for audio-visual synchronisation as measured by a SyncNet-like model. Therefore, a higher SyncNet score does not necessarily mean the video is perceptually more natural; it may partly reflect that the generation model is aligned with the evaluation metric.

This may partially explain why the generated videos can achieve stronger SyncNet alignment scores than the original video itself.

However, this does not necessarily mean that the Wav2Lip output is visually more natural. SyncNet measures audio-visual synchronisation, not perceptual realism.

## Noisy Audio Observations

When noise was added to the audio and passed directly into Wav2Lip, the generated videos often became visually less natural.

The main issue was that Wav2Lip appeared to react not only to the target speech but also to non-target acoustic events such as:

- background speech
- music energy
- cat meow sounds

This produced unnatural mouth movement in some videos, even when the SyncNet score was not extremely low.

This suggests that Wav2Lip is sensitive to the acoustic structure of the input mel spectrogram and does not reliably separate target speech from background interference.

## Noise Type Effects

### Background people noise

Background people noise was one of the most difficult conditions.

For original audio mixed with background people noise, the score was:

- AV offset: -2
- Min dist: 8.656
- Confidence: 4.592

This was the lowest confidence among the original-audio noisy Wav2Lip experiments.

Qualitatively, background speech was especially harmful because it contains speech-like patterns. These competing speech signals can drive the Wav2Lip mouth motion even though they do not belong to the visible speaker.

### Cat meow

The cat meow condition showed that even short non-speech acoustic events can affect Wav2Lip.

For original audio mixed with cat meow:

- AV offset: -2
- Min dist: 9.083
- Confidence: 5.081

The SyncNet confidence was not the worst, but the visual behaviour can still become unnatural if Wav2Lip responds to the non-speech event.

### Music: guitar, piano, violin

Music interference also affected Wav2Lip, although the severity varied.

Original audio mixed with guitar music:

- AV offset: -2
- Min dist: 8.445
- Confidence: 5.367

Original audio mixed with piano music:

- AV offset: -2
- Min dist: 8.224
- Confidence: 5.248

Original audio mixed with violin music:

- AV offset: -2
- Min dist: 8.146
- Confidence: 5.693

Music can introduce rhythmic and harmonic structure into the mel spectrogram. Wav2Lip may interpret some of this structure as speech-related audio variation, causing unnecessary mouth movement.

## DeepFilterNet3 Preprocessing Observations

DeepFilterNet3 improved the perceptual quality of the generated videos.

After denoising, the Wav2Lip outputs looked more stable and less affected by the added background interference. The audio was not perfectly restored, but it was cleaner than the noisy version, and the generated lip motion looked better.

The denoised SyncNet scores were:

| Condition | AV Offset | Min Dist | Confidence |
|---|---:|---:|---:|
| Background people + DeepFilterNet3 | -2 | 7.682 | 6.349 |
| Cat meow + DeepFilterNet3 | -2 | 7.965 | 6.622 |
| Guitar music + DeepFilterNet3 | -2 | 7.581 | 6.646 |
| Piano music + DeepFilterNet3 | -2 | 7.427 | 6.719 |
| Violin music + DeepFilterNet3 | -2 | 7.461 | 6.943 |

Compared with the noisy original-audio Wav2Lip results, DeepFilterNet3 increased confidence for all tested conditions.

The improvement was especially clear for background people noise:

- before denoising: 4.592
- after DeepFilterNet3: 6.349

This supports the idea that preprocessing can improve Wav2Lip robustness without changing the Wav2Lip model itself.

## Perceptual Quality vs SyncNet

A key observation is that SyncNet scores do not always fully match perceived visual quality.

Some noisy Wav2Lip outputs still received moderate SyncNet confidence scores, even when the video looked visually worse than expected.

This means:

- High SyncNet confidence does not always imply perceptually natural lip motion.
- Temporal synchronisation and perceptual realism are related but not identical objectives.

SyncNet is useful for measuring audio-visual temporal alignment, but it does not directly measure:

- mouth naturalness
- identity preservation
- visual artefacts
- whether the mouth is responding to the correct speaker
- whether non-speech sounds are incorrectly driving mouth movement

For a more complete evaluation, SyncNet should be combined with human inspection or additional visual quality metrics.

## Main Interpretation

The experiments suggest that Wav2Lip's main limitation under noisy conditions is not temporal alignment itself.

The main bottleneck appears to be the audio representation used for conditioning.

Wav2Lip uses mel spectrograms, which represent acoustic energy but do not explicitly distinguish:

- target speech
- background speech
- music
- animal sounds
- other non-speech noise

As a result, non-speech or competing-speech signals can influence the generated mouth motion.

## Why Preprocessing Helps

Preprocessing improves the input audio before it reaches Wav2Lip.

The intended pipeline is:

```text
Noisy waveform
→ speech enhancement / source separation
→ cleaner waveform
→ mel spectrogram
→ Wav2Lip
```

In this setup, Wav2Lip does not need to learn noise robustness directly. Instead, the upstream enhancement model reduces unwanted acoustic components before mel spectrogram extraction.

This is a practical approach because it does not require fine-tuning Wav2Lip.

## Future Work

Several follow-up directions are possible:

- Compare DeepFilterNet3 with other enhancement or separation models.
- Test speech-specific separation methods such as SepFormer.
- Add voice activity detection before Wav2Lip to suppress non-speech regions.
- Replace mel spectrogram conditioning with speech-aware representations such as HuBERT or WavLM.
- Fine-tune Wav2Lip using noisy audio augmentation, where the noisy input audio maps to clean target mouth motion.
- Add perceptual evaluation metrics alongside SyncNet.
- Evaluate whether background speech causes more degradation than music or non-speech events across a larger dataset.

## Summary

The experiments show that Wav2Lip can produce strong SyncNet alignment, but it is sensitive to noisy or non-speech audio conditioning.

DeepFilterNet3 preprocessing improves the results, especially under background speech noise, but it does not fully solve the problem.

The main conclusion is that robust audio-driven lip synchronisation requires more than temporal alignment. It also requires speech-aware audio conditioning and perceptual visual quality evaluation.
