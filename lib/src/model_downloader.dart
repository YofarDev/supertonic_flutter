import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
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

const List<String> _allModelFiles = [
  ..._onnxFiles,
  ..._voiceStyleFiles,
];

/// Callback for reporting download progress.
///
/// [completed] is the number of files already downloaded,
/// [total] is the total number of files to download,
/// [file] is the filename currently being downloaded,
/// and [fileProgress] is the progress of the current file (0.0–1.0).
typedef DownloadProgressCallback = void Function(
  int completed,
  int total,
  String file,
  double fileProgress,
);

/// Singleton that manages downloading and caching of Supertonic TTS model files
/// from Hugging Face.
///
/// Models are stored in the application support directory under a
/// `supertonic_models` subdirectory.
class ModelDownloader {
  ModelDownloader._();

  static final ModelDownloader instance = ModelDownloader._();

  static const String _modelDirName = 'supertonic_models';
  static const Duration _connectTimeout = Duration(seconds: 15);
  static const Duration _sendTimeout = Duration(seconds: 15);
  static const Duration _receiveTimeout = Duration(minutes: 5);

  Directory? _cachedModelDir;

  Future<Directory> get _modelDir async {
    if (_cachedModelDir != null) return _cachedModelDir!;
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory('${appDir.path}/$_modelDirName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    _cachedModelDir = dir;
    return dir;
  }

  /// Returns `true` when every file in [_allModelFiles] exists inside the
  /// model cache directory.
  Future<bool> allFilesExist() async {
    final dir = await _modelDir;
    for (final relative in _allModelFiles) {
      final file = File('${dir.path}/$relative');
      if (!file.existsSync()) return false;
    }
    return true;
  }

  /// Returns `true` when the bundled Flutter assets contain at least
  /// `assets/onnx/tts.json`, which is taken as proof that the plugin shipped
  /// with assets included.
  static Future<bool> assetsExist() async {
    try {
      await rootBundle.loadString('assets/onnx/tts.json');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Downloads every missing model file from Hugging Face.
  ///
  /// Files that already exist in the cache are skipped.  [onProgress] is
  /// invoked periodically to report per-file and overall progress.
  /// A [cancelToken] may be provided to cancel the download.
  Future<void> downloadAll({
    DownloadProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final dir = await _modelDir;
    final dio = Dio(
      BaseOptions(
        connectTimeout: _connectTimeout,
        sendTimeout: _sendTimeout,
        receiveTimeout: _receiveTimeout,
      ),
    );
    final total = _allModelFiles.length;
    var completed = 0;

    for (final relative in _allModelFiles) {
      final file = File('${dir.path}/$relative');
      if (file.existsSync()) {
        completed++;
        continue;
      }

      final parent = file.parent;
      if (!parent.existsSync()) {
        parent.createSync(recursive: true);
      }

      final url = '$_hfBase/$relative';
      final tmpFile = File('${file.path}.tmp');
      try {
        await dio.download(
          url,
          tmpFile.path,
          cancelToken: cancelToken,
          onReceiveProgress: (received, totalBytes) {
            final progress = totalBytes > 0 ? received / totalBytes : 0.0;
            onProgress?.call(completed, total, relative, progress);
          },
        );
        if (!tmpFile.existsSync() || tmpFile.lengthSync() == 0) {
          throw FileSystemException('Downloaded file is empty', relative);
        }
        await tmpFile.rename(file.path);
      } catch (_) {
        if (tmpFile.existsSync()) {
          tmpFile.deleteSync();
        }
        rethrow;
      }

      completed++;
      onProgress?.call(completed, total, relative, 1.0);
    }
  }

  /// Deletes the entire model cache directory so files will be re-downloaded.
  Future<void> deleteAll() async {
    final dir = await _modelDir;
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
      dir.createSync(recursive: true);
    }
  }

  /// Returns the absolute path for [relativePath] inside the model cache.
  Future<String> filePath(String relativePath) async {
    final dir = await _modelDir;
    return '${dir.path}/$relativePath';
  }

  /// Absolute path to the `onnx` subdirectory inside the model cache.
  Future<String> get onnxDir async {
    final dir = await _modelDir;
    return '${dir.path}/onnx';
  }

  /// Absolute path to the `voice_styles` subdirectory inside the model cache.
  Future<String> get voiceStylesDir async {
    final dir = await _modelDir;
    return '${dir.path}/voice_styles';
  }
}
