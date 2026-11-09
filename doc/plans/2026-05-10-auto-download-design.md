# Auto-Download Models from HuggingFace - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add auto-download of ONNX models from HuggingFace so developers can skip manual asset bundling. Three loading sources: cache → bundled assets → network download.

**Architecture:** All download logic lives in a new `ModelDownloader` class inside `supertonic_tts.dart`'s file scope. `SupertonicTTS.initialize()` gains a `_resolveModelSource()` step that checks app support dir → Flutter assets → triggers download. Two new public statics: `preDownloadModels()` and `modelsReady()`.

**Tech Stack:** `dio` for HTTP with progress callbacks, `path_provider` (already a dep) for app support dir.

---

### Task 1: Add `dio` dependency

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Add dio**

Run:
```bash
cd /Users/yofardev/development/Projects/Flutter/_utils/PLUGINS/supertonic_flutter
flutter pub add dio
```

**Step 2: Verify**

Run: `flutter pub get`
Expected: success, `dio` in pubspec.lock

**Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add dio dependency for model downloads"
```

---

### Task 2: Create `model_downloader.dart`

**Files:**
- Create: `lib/src/model_downloader.dart`

This file contains the `_ModelDownloader` class (private, internal). It knows:
- The HuggingFace base URL
- The file manifest (list of relative paths)
- How to check if all files exist in a local dir
- How to download all missing files with progress

**Step 1: Write the file**

```dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

const String _hfBase =
    'https://huggingface.co/Supertone/supertonic-2/resolve/main';

const List<String> _onnxFiles = [
  'onnx/duration_predictor.onnx',
  'onnx/text_encoder.onnx',
  'onnx/vector_estimator.onnx',
  'onnx/vocoder.onnx',
  'onnx/tts.json',
  'onnx/unicode_indexer.json',
];

const List<String> _voiceStyleFiles = [
  'voice_styles/F1.json',
  'voice_styles/F2.json',
  'voice_styles/F3.json',
  'voice_styles/F4.json',
  'voice_styles/F5.json',
  'voice_styles/M1.json',
  'voice_styles/M2.json',
  'voice_styles/M3.json',
  'voice_styles/M4.json',
  'voice_styles/M5.json',
];

const List<String> _allModelFiles = [..._onnxFiles, ..._voiceStyleFiles];

/// Callback for download progress.
///
/// [completed] is the number of files downloaded so far.
/// [total] is the total number of files.
/// [file] is the relative path of the file currently being downloaded.
/// [fileProgress] is 0.0–1.0 progress for the current file.
typedef DownloadProgressCallback = void Function(
  int completed,
  int total,
  String file,
  double fileProgress,
);

class ModelDownloader {
  static final ModelDownloader _instance = ModelDownloader._();
  ModelDownloader._();

  static ModelDownloader get instance => _instance;

  /// Directory name under app support dir for storing models.
  static const String _modelDirName = 'supertonic_models';

  /// Returns the local directory where models are cached.
  Future<Directory> get _modelDir async {
    final supportDir = await getApplicationSupportDirectory();
    final dir = Directory('${supportDir.path}/$_modelDirName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  /// Checks if all model files exist in the cache directory.
  Future<bool> allFilesExist() async {
    final dir = await _modelDir;
    for (final relativePath in _allModelFiles) {
      final file = File('${dir.path}/$relativePath');
      if (!file.existsSync()) return false;
    }
    return true;
  }

  /// Checks if bundled Flutter assets for onnx models exist.
  static Future<bool> assetsExist() async {
    try {
      await rootBundle.loadString('assets/onnx/tts.json');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Downloads all missing model files from HuggingFace.
  ///
  /// Returns the directory where files were saved.
  /// Throws on network errors.
  Future<Directory> downloadAll({
    DownloadProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final dir = await _modelDir;
    final dio = Dio();

    for (var i = 0; i < _allModelFiles.length; i++) {
      final relativePath = _allModelFiles[i];
      final file = File('${dir.path}/$relativePath');

      if (file.existsSync()) {
        onProgress?.call(i + 1, _allModelFiles.length, relativePath, 1.0);
        continue;
      }

      // Ensure parent directory exists
      file.parent.createSync(recursive: true);

      final url = '$_hfBase/$relativePath';
      await dio.download(
        url,
        file.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          final progress = total > 0 ? received / total : 0.0;
          onProgress?.call(i, _allModelFiles.length, relativePath, progress);
        },
      );
      onProgress?.call(i + 1, _allModelFiles.length, relativePath, 1.0);
    }

    return dir;
  }

  /// Returns the absolute path for a model file in the cache.
  Future<String> filePath(String relativePath) async {
    final dir = await _modelDir;
    return '${dir.path}/$relativePath';
  }

  /// Returns the absolute directory path for onnx models.
  Future<String> get onnxDir async {
    final dir = await _modelDir;
    return '${dir.path}/onnx';
  }

  /// Returns the absolute directory path for voice styles.
  Future<String> get voiceStylesDir async {
    final dir = await _modelDir;
    return '${dir.path}/voice_styles';
  }
}
```

Note: needs `import 'package:flutter/services.dart' show rootBundle;` at top for `assetsExist()`.

**Step 2: Verify no analysis errors**

Run: `cd /Users/yofardev/development/Projects/Flutter/_utils/PLUGINS/supertonic_flutter && flutter analyze lib/src/model_downloader.dart`
Expected: no errors

**Step 3: Commit**

```bash
git add lib/src/model_downloader.dart
git commit -m "feat: add ModelDownloader for HuggingFace model downloads"
```

---

### Task 3: Modify `SupertonicTTS` to use auto-detect loading

**Files:**
- Modify: `lib/src/supertonic_tts.dart`

**What changes:**

1. Import `model_downloader.dart` and `dart:io`
2. Add `_modelSource` enum or field to track where models came from
3. Modify `initialize()`:
   - Try `_ModelDownloader.instance.allFilesExist()` → load from cache
   - Else try `_ModelDownloader.assetsExist()` → copy assets to cache, load
   - Else → download from HF, load
4. Modify `_loadCfgs()` to accept a resolved local path (file read, not rootBundle)
5. Modify `_loadStyle()` to accept resolved local path (file read, not rootBundle)
6. Modify `_UnicodeProcessor.load()` to work with resolved paths
7. Add `static Future<void> preDownloadModels(...)` and `static Future<bool> modelsReady()`

**Step 1: Rewrite `initialize()` method**

The new `initialize()` signature stays the same but internals change:

```dart
Future<void> initialize({
  String onnxDir = 'assets/onnx',
  String voiceStylesDir = 'assets/voice_styles',
}) async {
  if (_isInitialized) return;

  final downloader = ModelDownloader.instance;

  if (await downloader.allFilesExist()) {
    // Source 1: already cached locally
    final localOnnx = await downloader.onnxDir;
    final localVoices = await downloader.voiceStylesDir;
    _cfgs = await _loadCfgsFromFile(localOnnx);
    final sessions = await _loadOnnxAllFromFiles(localOnnx);
    _textProcessor = await _UnicodeProcessor.load('$localOnnx/unicode_indexer.json');
    _voiceStylesDir = localVoices;
    _assignSessions(sessions);
  } else if (await ModelDownloader.assetsExist()) {
    // Source 2: bundled Flutter assets — copy to cache then load
    await _copyAssetsToCache(onnxDir, voiceStylesDir);
    final localOnnx = await downloader.onnxDir;
    final localVoices = await downloader.voiceStylesDir;
    _cfgs = await _loadCfgsFromFile(localOnnx);
    final sessions = await _loadOnnxAllFromFiles(localOnnx);
    _textProcessor = await _UnicodeProcessor.load('$localOnnx/unicode_indexer.json');
    _voiceStylesDir = localVoices;
    _assignSessions(sessions);
  } else {
    // Source 3: download from HuggingFace
    await downloader.downloadAll();
    final localOnnx = await downloader.onnxDir;
    final localVoices = await downloader.voiceStylesDir;
    _cfgs = await _loadCfgsFromFile(localOnnx);
    final sessions = await _loadOnnxAllFromFiles(localOnnx);
    _textProcessor = await _UnicodeProcessor.load('$localOnnx/unicode_indexer.json');
    _voiceStylesDir = localVoices;
    _assignSessions(sessions);
  }

  _isInitialized = true;
}
```

**Step 2: Add helper methods**

```dart
String? _voiceStylesDir;

void _assignSessions(Map<String, OrtSession> sessions) {
  _dpOrt = sessions['dpOrt'];
  _textEncOrt = sessions['textEncOrt'];
  _vectorEstOrt = sessions['vectorEstOrt'];
  _vocoderOrt = sessions['vocoderOrt'];
}

Future<Map<String, dynamic>> _loadCfgsFromFile(String dir) async {
  final file = File('$dir/tts.json');
  final json = jsonDecode(await file.readAsString());
  return json as Map<String, dynamic>;
}

Future<Map<String, OrtSession>> _loadOnnxAllFromFiles(String dir) async {
  final ort = OnnxRuntime();
  final models = ['duration_predictor', 'text_encoder', 'vector_estimator', 'vocoder'];
  final sessions = await Future.wait(models.map((name) async {
    return ort.createSessionFromAsset('$dir/$name.onnx');
  }));
  return {
    'dpOrt': sessions[0],
    'textEncOrt': sessions[1],
    'vectorEstOrt': sessions[2],
    'vocoderOrt': sessions[3],
  };
}

/// Copy bundled Flutter assets to the model cache directory.
Future<void> _copyAssetsToCache(String onnxDir, String voiceStylesDir) async {
  final downloader = ModelDownloader.instance;
  final modelDir = await downloader._modelDir;

  // Copy onnx files
  final onnxAssets = [
    'duration_predictor.onnx', 'text_encoder.onnx',
    'vector_estimator.onnx', 'vocoder.onnx',
    'tts.json', 'unicode_indexer.json',
  ];
  for (final name in onnxAssets) {
    final byteData = await rootBundle.load('$onnxDir/$name');
    final file = File('${modelDir.path}/onnx/$name');
    file.parent.createSync(recursive: true);
    if (!file.existsSync()) {
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
  }

  // Copy voice style files
  final voiceAssets = ['M1', 'M2', 'M3', 'M4', 'M5', 'F1', 'F2', 'F3', 'F4', 'F5'];
  for (final name in voiceAssets) {
    final byteData = await rootBundle.load('$voiceStylesDir/$name.json');
    final file = File('${modelDir.path}/voice_styles/$name.json');
    file.parent.createSync(recursive: true);
    if (!file.existsSync()) {
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
  }
}
```

**Step 3: Update `_loadStyle()` to use resolved dir**

Change from:
```dart
final path = 'assets/voice_styles/$voiceStyle.json';
final json = jsonDecode(await rootBundle.loadString(path));
```
To:
```dart
final String path;
if (_voiceStylesDir != null) {
  path = '$_voiceStylesDir/$voiceStyle.json';
} else {
  path = 'assets/voice_styles/$voiceStyle.json';
}
final jsonStr = _voiceStylesDir != null
    ? await File(path).readAsString()
    : await rootBundle.loadString(path);
final json = jsonDecode(jsonStr);
```

**Step 4: Add public static methods**

```dart
/// Pre-downloads all model files from HuggingFace.
///
/// Use this to download models at a convenient time (e.g., app startup,
/// background task) instead of waiting for the first [initialize] call.
///
/// [onProgress] reports download progress: (filesCompleted, totalFiles, currentFileName, currentFileProgress).
/// [cancelToken] can be used to cancel the download.
///
/// Example:
/// ```dart
/// await SupertonicTTS.preDownloadModels(
///   onProgress: (done, total, file, progress) {
///     print('[$done/$total] $file: ${(progress * 100).toInt()}%');
///   },
/// );
/// ```
static Future<void> preDownloadModels({
  DownloadProgressCallback? onProgress,
  CancelToken? cancelToken,
}) async {
  await ModelDownloader.instance.downloadAll(
    onProgress: onProgress,
    cancelToken: cancelToken,
  );
}

/// Checks if all required model files are available locally.
///
/// Returns `true` if models are cached and ready for [initialize].
/// Does not require network access.
///
/// Example:
/// ```dart
/// if (!await SupertonicTTS.modelsReady()) {
///   await SupertonicTTS.preDownloadModels();
/// }
/// await tts.initialize();
/// ```
static Future<bool> modelsReady() async {
  final downloader = ModelDownloader.instance;
  if (await downloader.allFilesExist()) return true;
  return await ModelDownloader.assetsExist();
}
```

**Step 5: Export `DownloadProgressCallback` from barrel file**

Modify `lib/supertonic_flutter.dart` to add:
```dart
export 'src/model_downloader.dart' show DownloadProgressCallback;
```

**Step 6: Verify**

Run: `cd /Users/yofardev/development/Projects/Flutter/_utils/PLUGINS/supertonic_flutter && flutter analyze`
Expected: no errors

**Step 7: Commit**

```bash
git add lib/src/supertonic_tts.dart lib/src/model_downloader.dart lib/supertonic_flutter.dart
git commit -m "feat: auto-detect model source with HuggingFace fallback"
```

---

### Task 4: Update CHANGELOG.md

**Files:**
- Modify: `CHANGELOG.md`

**Step 1: Add 1.0.0 entry**

Prepend to CHANGELOG.md:

```markdown
## 1.0.0

- **Breaking**: Models are now auto-downloaded from HuggingFace when not bundled as assets
- Added automatic model source detection: local cache → bundled assets → HuggingFace download
- Added `SupertonicTTS.preDownloadModels()` for explicit model pre-downloading with progress callback
- Added `SupertonicTTS.modelsReady()` to check if models are available locally
- Added `DownloadProgressCallback` typedef for download progress reporting
- Bundled assets still supported — no code changes needed for existing setups
```

**Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: update changelog for 1.0.0"
```

---

### Task 5: Update README.md

**Files:**
- Modify: `README.md`

**Step 1: Rewrite Setup section**

Replace the "Setup" section (lines 33-62) with two approaches:

```markdown
## Setup

### Option A: Auto-Download (Recommended)

No manual setup required. Models are automatically downloaded from [Hugging Face](https://huggingface.co/Supertone/supertonic-2) on first use (~268 MB).

```dart
// Just initialize — models download automatically if not found
final tts = SupertonicTTS();
await tts.initialize();
```

To pre-download at a convenient time:

```dart
// Check if models are ready
if (!await SupertonicTTS.modelsReady()) {
  await SupertonicTTS.preDownloadModels(
    onProgress: (done, total, file, progress) {
      print('[$done/$total] $file: ${(progress * 100).toInt()}%');
    },
  );
}
```

### Option B: Bundle Assets Manually

Download model files from [Hugging Face](https://huggingface.co/Supertone/supertonic-2) and add them to your app's assets directory. This avoids runtime downloads but increases app size by ~268 MB.

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

Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/onnx/
    - assets/voice_styles/
```

### Platform Configuration
```

The Platform Configuration section stays the same. Update the Installation version to `^1.0.0`.

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update readme for 1.0.0 with auto-download instructions"
```

---

### Task 6: Bump version to 1.0.0

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Update version**

Change `version: 0.1.3` to `version: 1.0.0` in `pubspec.yaml`.

**Step 2: Verify**

Run: `cd /Users/yofardev/development/Projects/Flutter/_utils/PLUGINS/supertonic_flutter && flutter analyze`
Expected: no errors

**Step 3: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: bump version to 1.0.0"
```

---

### Task 7: Final verification

**Step 1: Full analysis**

Run: `cd /Users/yofardev/development/Projects/Flutter/_utils/PLUGINS/supertonic_flutter && flutter analyze`
Expected: no errors

**Step 2: Review all changes**

Run: `git log --oneline main..HEAD`
Expected: 6 commits covering all tasks above.

**Step 3: Final commit (if any fixes needed)**

Fix any issues found during analysis.
