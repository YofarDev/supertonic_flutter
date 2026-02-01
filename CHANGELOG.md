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
