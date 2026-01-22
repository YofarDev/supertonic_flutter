# Supertonic TTS Flutter

High-quality multilingual text-to-speech (TTS) engine for Flutter applications. Powered by ONNX Runtime for fast, local neural speech synthesis.

> **Note:** This is an unofficial Flutter port of the [Supertonic](https://github.com/supertone-inc/supertonic) project.

## Features

- 🌍 **Multilingual Support** - English, Korean, Spanish, Portuguese, and French
- 🎭 **Multiple Voice Styles** - 10 unique voices (5 male, 5 female) with different characteristics
- ⚡ **Local Processing** - All inference happens on-device, no server calls required
- 🎛️ **Customizable** - Adjustable speech speed and quality settings
- 📱 **Cross-Platform** - Supports Android, iOS, and macOS
- 🔊 **High Quality** - Neural TTS powered by advanced diffusion models

## Platform Support

| Platform | Status       | Minimum Version       |
| -------- | ------------ | --------------------- |
| Android  | ✅ Supported | API 21+ (Android 5.0) |
| iOS      | ✅ Supported | iOS 16.0+             |
| macOS    | ✅ Supported | macOS 14.0+           |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  supertonic_flutter: ^0.1.0
```

## Setup

### 1. Add Assets

Add the ONNX model files and voice styles to your app's assets directory:

> **Note:** Model files are not included in the package due to their size. Download them from [Hugging Face](https://huggingface.co/Supertone/supertonic-2) and add them to your app.

```
assets/
├── onnx/
│   ├── duration_predictor.onnx
│   ├── text_encoder.onnx
│   ├── vector_estimator.onnx
│   ├── vocoder.onnx
│   ├── tts.json
│   └── unicode_indexer.json
└── voice_styles/
    ├── M1.json, M2.json, M3.json, M4.json, M5.json
    └── F1.json, F2.json, F3.json, F4.json, F5.json
```

### 2. Update pubspec.yaml

```yaml
flutter:
  assets:
    - assets/onnx/
    - assets/voice_styles/
```

### 3. Platform Configuration

This package uses `flutter_onnxruntime` which requires specific platform configurations:

#### Android

Add ProGuard rules to prevent ONNX Runtime classes from being obfuscated.

Create or edit `android/app/proguard-rules.pro`:

```proguard
-keep class ai.onnxruntime.** { *; }
```

Or run this command from your terminal:

```bash
echo "-keep class ai.onnxruntime.** { *; }" > android/app/proguard-rules.pro
```

For more information, refer to the [flutter_onnxruntime troubleshooting guide](https://github.com/innovation-engineering/flutter_onnxruntime/blob/main/README.md#troubleshooting).

#### iOS

ONNX Runtime requires minimum version iOS 16 and static linkage.

In `ios/Podfile`, update the following lines:

```ruby
platform :ios, '16.0'

# ... existing code ...

target 'Runner' do
  use_frameworks! :linkage => :static

  # ... existing code ...
end
```

And add to the `post_install` hook:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end
```

#### macOS

macOS build requires minimum version macOS 14.

In `macos/Podfile`, change:

```ruby
platform :osx, '14.0'
```

Update the "Minimum Deployments" to 14.0 in Xcode:

```bash
open macos/Runner.xcworkspace
```

Then in Xcode:

1. Select **Runner** project in the navigator
2. Select **Runner** target
3. Go to **General** tab
4. Change **Minimum Deployments** to **14.0**

Also add to the `post_install` hook in your Podfile:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_macos_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '14.0'
      config.build_settings['ALLOW_STATIC_FRAMEWORK_TRANSITIVE_DEPENDENCIES'] = 'YES'
    end
  end
end
```

## Demo

<img src="example/screen.png" alt="Supertonic Flutter Demo" width="300"/>

> Check out the `example/` directory for a full-featured demo app with language selection, voice switching, and customizable settings.

## Usage

### Basic Example

```dart
import 'package:supertonic_flutter/supertonic_flutter.dart';

// Initialize the TTS engine
final tts = SupertonicTTS();
await tts.initialize();

// Synthesize speech
final result = await tts.synthesize(
  'Hello, world!',
  language: 'en',
  voiceStyle: 'M1',
);

// Convert to WAV and save
final wavBytes = result.toWavBytes();
final file = File('output.wav');
await file.writeAsBytes(wavBytes);
```

### With Audio Player

```dart
import 'package:supertonic_flutter/supertonic_flutter.dart';

final tts = SupertonicTTS();
final player = TTSAudioPlayer();

// Initialize
await tts.initialize();

// Synthesize and play
final result = await tts.synthesize(
  'Hello, this is a test.',
  language: 'en',
  voiceStyle: 'F1',
  config: TTSConfig(
    speechSpeed: 1.05,
    denoisingSteps: 5,
  ),
);

await player.play(result);
```

## License

See LICENSE file for details.
