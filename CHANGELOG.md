## Unreleased

- Fix: `chunkText()` only recognized ASCII `.`/`!`/`?` as sentence-enders, so text in scripts using other sentence-ending punctuation (e.g. Hindi's Devanagari danda `।`/`॥`, CJK fullwidth `。！？`, Arabic `؟`) was treated as one unbounded "sentence" with no `maxLen` cap enforced — causing synthesis failures on long text and inconsistent speech pacing. `chunkText()` now recognizes these scripts' punctuation and falls back to word-then-character-level splitting for any sentence still exceeding `maxLen` (a safety net that previously didn't exist at all).

## 2.0.0

**Breaking** — upgraded to [Supertonic 3](https://huggingface.co/Supertone/supertonic-3).

- Language support expanded from 5 to **31 languages** (English, Korean, Japanese, Spanish, Portuguese, French, German, Italian, Dutch, Russian, Ukrainian, Polish, Czech, Slovak, Croatian, Slovenian, Bulgarian, Romanian, Hungarian, Greek, Swedish, Danish, Finnish, Estonian, Latvian, Lithuanian, Turkish, Arabic, Hindi, Indonesian, Vietnamese)
- Model assets now downloaded from `Supertone/supertonic-3` (~400 MB)
- Versioned model cache (`supertonic_models_v3`): existing Supertonic 2 caches are orphaned and the new model is re-downloaded on first run, preventing silent stale-model loads
- Example app: flags added for all 31 languages
- Maintenance: Flutter migrator gradle flags applied

## 1.0.0

- Auto-download model files from HuggingFace when not bundled as assets
- Three-strategy model loading: local cache → bundled Flutter assets → network download
- Added `SupertonicTTS.preDownloadModels()` for explicit model pre-downloading with progress callback
- Added `SupertonicTTS.modelsReady()` to check if models are available locally
- Added `DownloadProgressCallback` typedef for download progress reporting
- Bundled assets still supported — no code changes needed for existing setups

## 0.1.5

- Added Web platform support
- Added web plugin registration (`SupertonicFlutterWebPlugin`)
- Reworked ONNX model loading to use asset-based session creation across platforms
- Added Web setup instructions for loading `onnxruntime-web` in `web/index.html`
- Fixed Web TTS inference for `tensor(int64)` model inputs
- Updated audio playback to in-memory byte source for better cross-platform compatibility

## 0.1.4

- Added Linux desktop support
- Migrated from just_audio to audioplayers for cross-platform audio playback

## 0.1.3

- Removed verbose logs at init

## 0.1.2

- Added comprehensive inline documentation for all public APIs
  - Enhanced TTSConfig with detailed parameter documentation including quality/speed trade-offs
  - Added detailed voice style descriptions for all 10 voices (M1-M5, F1-F5)
  - Documented all supported languages with examples
  - Added usage examples throughout the API
- Removed redundant `gender` field from `TTSVoiceStyle` (gender is indicated by voice code prefix)
- Improved code documentation for better IDE hover tooltips
- Updated example app to include silence duration slider, making all TTSConfig parameters adjustable from UI

## 0.1.1

- Minor README improvements

## 0.1.0

- Initial release of supertonic_flutter
- Support for multiple languages: English, Korean, Spanish, Portuguese, and French
- Multiple voice styles for each language
- Cross-platform support: Android, iOS, and macOS
- ONNX-based text-to-speech engine
- Configurable speech rate, pitch, and volume
- Audio playback with pause, resume, and stop controls
- Stream-based audio generation
