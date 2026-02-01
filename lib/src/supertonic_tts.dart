import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'tts_config.dart';
import 'tts_result.dart';

final _logger = Logger(
  printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 80),
);

// Hangul Jamo constants for NFKD decomposition
const int _hangulSyllableBase = 0xAC00;
const int _hangulSyllableEnd = 0xD7A3;
const int _leadingJamoBase = 0x1100;
const int _vowelJamoBase = 0x1161;
const int _trailingJamoBase = 0x11A7;
const int _vowelCount = 21;
const int _trailingCount = 28;

/// Latin character decompositions (NFKD) for es, pt, fr
const Map<int, List<int>> _latinDecompositions = {
  0x00C1: [0x0041, 0x0301],
  0x00C9: [0x0045, 0x0301],
  0x00CD: [0x0049, 0x0301],
  0x00D3: [0x004F, 0x0301],
  0x00DA: [0x0055, 0x0301],
  0x00E1: [0x0061, 0x0301],
  0x00E9: [0x0065, 0x0301],
  0x00ED: [0x0069, 0x0301],
  0x00F3: [0x006F, 0x0301],
  0x00FA: [0x0075, 0x0301],
  0x00C0: [0x0041, 0x0300],
  0x00C8: [0x0045, 0x0300],
  0x00CC: [0x0049, 0x0300],
  0x00D2: [0x004F, 0x0300],
  0x00D9: [0x0055, 0x0300],
  0x00E0: [0x0061, 0x0300],
  0x00E8: [0x0065, 0x0300],
  0x00EC: [0x0069, 0x0300],
  0x00F2: [0x006F, 0x0300],
  0x00F9: [0x0075, 0x0300],
  0x00C2: [0x0041, 0x0302],
  0x00CA: [0x0045, 0x0302],
  0x00CE: [0x0049, 0x0302],
  0x00D4: [0x004F, 0x0302],
  0x00DB: [0x0055, 0x0302],
  0x00E2: [0x0061, 0x0302],
  0x00EA: [0x0065, 0x0302],
  0x00EE: [0x0069, 0x0302],
  0x00F4: [0x006F, 0x0302],
  0x00FB: [0x0075, 0x0302],
  0x00C3: [0x0041, 0x0303],
  0x00D1: [0x004E, 0x0303],
  0x00D5: [0x004F, 0x0303],
  0x00E3: [0x0061, 0x0303],
  0x00F1: [0x006E, 0x0303],
  0x00F5: [0x006F, 0x0303],
  0x00C4: [0x0041, 0x0308],
  0x00CB: [0x0045, 0x0308],
  0x00CF: [0x0049, 0x0308],
  0x00D6: [0x004F, 0x0308],
  0x00DC: [0x0055, 0x0308],
  0x00E4: [0x0061, 0x0308],
  0x00EB: [0x0065, 0x0308],
  0x00EF: [0x0069, 0x0308],
  0x00F6: [0x006F, 0x0308],
  0x00FC: [0x0075, 0x0308],
  0x00C7: [0x0043, 0x0327],
  0x00E7: [0x0063, 0x0327],
};

/// Decompose a Hangul syllable into Jamo (NFKD-like decomposition)
List<int> _decomposeHangulSyllable(int codePoint) {
  if (codePoint < _hangulSyllableBase || codePoint > _hangulSyllableEnd) {
    return [codePoint];
  }

  final syllableIndex = codePoint - _hangulSyllableBase;
  final leadingIndex = syllableIndex ~/ (_vowelCount * _trailingCount);
  final vowelIndex =
      (syllableIndex % (_vowelCount * _trailingCount)) ~/ _trailingCount;
  final trailingIndex = syllableIndex % _trailingCount;

  final result = <int>[
    _leadingJamoBase + leadingIndex,
    _vowelJamoBase + vowelIndex,
  ];

  if (trailingIndex > 0) {
    result.add(_trailingJamoBase + trailingIndex);
  }

  return result;
}

/// Apply NFKD-like decomposition (Hangul + Latin accented characters)
String _applyNfkdDecomposition(String text) {
  final result = <int>[];
  for (final codePoint in text.runes) {
    if (codePoint >= _hangulSyllableBase && codePoint <= _hangulSyllableEnd) {
      result.addAll(_decomposeHangulSyllable(codePoint));
    } else if (_latinDecompositions.containsKey(codePoint)) {
      result.addAll(_latinDecompositions[codePoint]!);
    } else {
      result.add(codePoint);
    }
  }
  return String.fromCharCodes(result);
}

/// Preprocess text for TTS
String _preprocessText(String text, String lang) {
  text = _applyNfkdDecomposition(text);

  // Remove emojis
  text = text.replaceAll(
      RegExp(
        r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|'
        r'[\u{1F700}-\u{1F77F}]|[\u{1F780}-\u{1F7FF}]|[\u{1F800}-\u{1F8FF}]|'
        r'[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|'
        r'[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F1E6}-\u{1F1FF}]',
        unicode: true,
      ),
      '');

  // Replace various dashes and symbols
  const replacements = {
    '–': '-',
    '‑': '-',
    '—': '-',
    '_': ' ',
    '\u201C': '"',
    '\u201D': '"',
    '\u2018': "'",
    '\u2019': "'",
    '´': "'",
    '`': "'",
    '[': ' ',
    ']': ' ',
    '|': ' ',
    '/': ' ',
    '#': ' ',
    '→': ' ',
    '←': ' ',
  };
  for (final entry in replacements.entries) {
    text = text.replaceAll(entry.key, entry.value);
  }

  // Remove special symbols
  text = text.replaceAll(RegExp(r'[♥☆♡©\\]'), '');

  // Replace known expressions
  text = text.replaceAll('@', ' at ');
  text = text.replaceAll('e.g.,', 'for example, ');
  text = text.replaceAll('i.e.,', 'that is, ');

  // Fix spacing around punctuation
  text = text.replaceAll(' ,', ',');
  text = text.replaceAll(' .', '.');
  text = text.replaceAll(' !', '!');
  text = text.replaceAll(' ?', '?');
  text = text.replaceAll(' ;', ';');
  text = text.replaceAll(' :', ':');
  text = text.replaceAll(" '", "'");

  // Remove duplicate quotes
  while (text.contains('""')) {
    text = text.replaceAll('""', '"');
  }
  while (text.contains("''")) {
    text = text.replaceAll("''", "'");
  }
  while (text.contains('``')) {
    text = text.replaceAll('``', '`');
  }

  // Remove extra spaces
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Add period if needed
  if (text.isNotEmpty &&
      !RegExp(r'[.!?;:,\x27\x22\u2018\u2019)\]}…。」』】〉》›»]$').hasMatch(text)) {
    text += '.';
  }

  // Wrap text with language tags
  text = '<$lang>$text</$lang>';

  return text;
}

class _UnicodeProcessor {
  final Map<int, int> indexer;

  _UnicodeProcessor._(this.indexer);

  static Future<_UnicodeProcessor> load(String path) async {
    final json = jsonDecode(
      path.startsWith('assets/')
          ? await rootBundle.loadString(path)
          : File(path).readAsStringSync(),
    );

    final indexer = json is List
        ? {
            for (var i = 0; i < json.length; i++)
              if (json[i] is int && json[i] >= 0) i: json[i] as int
          }
        : (json as Map<String, dynamic>)
            .map((k, v) => MapEntry(int.parse(k), v as int));

    return _UnicodeProcessor._(indexer);
  }

  Map<String, dynamic> call(List<String> textList, List<String> langList) {
    final processedTexts = <String>[];
    for (var i = 0; i < textList.length; i++) {
      processedTexts.add(_preprocessText(textList[i], langList[i]));
    }

    final lengths = processedTexts.map((t) => t.runes.length).toList();
    final maxLen = lengths.reduce(math.max);

    final textIds = processedTexts.map((text) {
      final row = List<int>.filled(maxLen, 0);
      final runes = text.runes.toList();
      for (var i = 0; i < runes.length; i++) {
        row[i] = indexer[runes[i]] ?? 0;
      }
      return row;
    }).toList();

    return {'textIds': textIds, 'textMask': _lengthToMask(lengths)};
  }

  List<List<List<double>>> _lengthToMask(List<int> lengths, [int? maxLen]) {
    maxLen ??= lengths.reduce(math.max);
    return lengths
        .map((len) => [List.generate(maxLen!, (i) => i < len ? 1.0 : 0.0)])
        .toList();
  }
}

class _Style {
  final OrtValue ttl, dp;
  final List<int> ttlShape, dpShape;
  _Style(this.ttl, this.dp, this.ttlShape, this.dpShape);
}

/// Main Supertonic TTS engine for high-quality neural text-to-speech synthesis.
///
/// This class provides the core functionality for converting text to speech
/// using ONNX Runtime for fast, local inference. Supports multiple languages
/// and voice styles with customizable quality settings.
///
/// Example:
/// ```dart
/// final tts = SupertonicTTS();
///
/// // Initialize the engine
/// await tts.initialize();
///
/// // Synthesize speech
/// final result = await tts.synthesize(
///   'Hello, world!',
///   language: 'en',
///   voiceStyle: 'M1',
/// );
///
/// // Use the result
/// final wavBytes = result.toWavBytes();
/// await File('output.wav').writeAsBytes(wavBytes);
///
/// // Clean up when done
/// tts.dispose();
/// ```
///
/// See also:
/// - [TTSConfig] for configuration options
/// - [TTSAudioPlayer] for playing synthesized audio
/// - [TTSVoiceStyle] for available voice styles
/// - [TTSLanguage] for supported languages
class SupertonicTTS {
  _UnicodeProcessor? _textProcessor;
  OrtSession? _dpOrt, _textEncOrt, _vectorEstOrt, _vocoderOrt;
  Map<String, dynamic>? _cfgs;

  final Map<String, _Style> _styleCache = {};

  /// The audio sample rate in Hz (typically 24000).
  ///
  /// This is used when encoding the output audio data.
  int get sampleRate => _cfgs?['ae']?['sample_rate'] ?? 24000;

  /// The base chunk size for audio processing (typically 512).
  ///
  /// This affects how the audio is processed internally.
  int get baseChunkSize => _cfgs?['ae']?['base_chunk_size'] ?? 512;

  /// The chunk compression factor (typically 2).
  ///
  /// Used for internal audio processing calculations.
  int get chunkCompressFactor => _cfgs?['ttl']?['chunk_compress_factor'] ?? 2;

  /// The latent dimension (typically 512).
  ///
  /// Used for internal model processing.
  int get ldim => _cfgs?['ttl']?['latent_dim'] ?? 512;

  bool _isInitialized = false;

  /// Whether the TTS engine has been initialized.
  ///
  /// Returns `true` if [initialize] has been successfully called.
  ///
  /// Example:
  /// ```dart
  /// if (!tts.isInitialized) {
  ///   await tts.initialize();
  /// }
  /// ```
  bool get isInitialized => _isInitialized;

  /// Initializes the TTS engine and loads ONNX models.
  ///
  /// Must be called before any synthesis operations. This method loads the
  /// necessary ONNX models, configuration files, and text processors.
  ///
  /// The [onnxDir] parameter specifies the directory containing ONNX model files:
  /// - duration_predictor.onnx
  /// - text_encoder.onnx
  /// - vector_estimator.onnx
  /// - vocoder.onnx
  /// - tts.json
  /// - unicode_indexer.json
  ///
  /// The [voiceStylesDir] parameter specifies the directory containing voice style
  /// JSON files (M1.json, M2.json, etc.).
  ///
  /// Example:
  /// ```dart
  /// final tts = SupertonicTTS();
  ///
  /// // Initialize with default paths
  /// await tts.initialize();
  ///
  /// // Or specify custom paths
  /// await tts.initialize(
  ///   onnxDir: 'custom/path/to/onnx',
  ///   voiceStylesDir: 'custom/path/to/voices',
  /// );
  /// ```
  ///
  /// Throws:
  /// - [StateError] if already initialized
  /// - [Exception] if model files are missing or invalid
  ///
  /// See also:
  /// - [synthesize] for generating speech
  /// - [dispose] for cleaning up resources
  Future<void> initialize({
    String onnxDir = 'assets/onnx',
    String voiceStylesDir = 'assets/voice_styles',
  }) async {
    if (_isInitialized) return;

    _logger.i('Initializing SupertonicTTS...');

    _cfgs = await _loadCfgs(onnxDir);
    final sessions = await _loadOnnxAll(onnxDir);
    _textProcessor =
        await _UnicodeProcessor.load('$onnxDir/unicode_indexer.json');

    _dpOrt = sessions['dpOrt'];
    _textEncOrt = sessions['textEncOrt'];
    _vectorEstOrt = sessions['vectorEstOrt'];
    _vocoderOrt = sessions['vocoderOrt'];

    _isInitialized = true;
    _logger.i('SupertonicTTS initialized successfully');
  }

  /// Synthesizes speech from the given text.
  ///
  /// Converts the provided [text] into audio using the specified [language] and
  /// [voiceStyle]. The [config] parameter allows customization of quality and speed.
  ///
  /// The [text] parameter can be any length. Long text is automatically chunked
  /// and synthesized in segments with optional silence between chunks.
  ///
  /// The [language] parameter must be one of the supported language codes:
  /// - 'en' - English
  /// - 'ko' - Korean
  /// - 'es' - Spanish
  /// - 'pt' - Portuguese
  /// - 'fr' - French
  ///
  /// The [voiceStyle] parameter selects one of the 10 available voices:
  /// - Male: 'M1', 'M2', 'M3', 'M4', 'M5'
  /// - Female: 'F1', 'F2', 'F3', 'F4', 'F5'
  ///
  /// The [config] parameter is optional. If not provided, default settings are used.
  /// See [TTSConfig] for available options.
  ///
  /// Example:
  /// ```dart
  /// // Basic synthesis
  /// final result = await tts.synthesize(
  ///   'Hello, world!',
  ///   language: 'en',
  ///   voiceStyle: 'M1',
  /// );
  ///
  /// // With custom configuration
  /// final result = await tts.synthesize(
  ///   'This is a longer text that will be split into chunks.',
  ///   language: 'en',
  ///   voiceStyle: 'F3',
  ///   config: TTSConfig(
  ///     speechSpeed: 1.2,
  ///     denoisingSteps: 8,
  ///     silenceDuration: 0.5,
  ///   ),
  /// );
  ///
  /// // Use the result
  /// await player.play(result);
  /// // Or save to file
  /// final wavBytes = result.toWavBytes();
  /// await File('output.wav').writeAsBytes(wavBytes);
  /// ```
  ///
  /// Returns a [TTSResult] containing the synthesized audio data, sample rate,
  /// and duration.
  ///
  /// Throws:
  /// - [StateError] if the engine is not initialized (call [initialize] first)
  /// - [Exception] if synthesis fails due to invalid input or model errors
  ///
  /// See also:
  /// - [TTSConfig] for configuration options
  /// - [TTSVoiceStyle] for voice descriptions
  /// - [TTSLanguage] for supported languages
  /// - [TTSAudioPlayer.play] for playing the result
  Future<TTSResult> synthesize(
    String text, {
    String language = 'en',
    String? voiceStyle,
    TTSConfig? config,
  }) async {
    if (!_isInitialized) {
      throw StateError(
          'SupertonicTTS not initialized. Call initialize() first.');
    }

    final effectiveConfig = config ?? const TTSConfig();
    final style = await _loadStyle(voiceStyle ?? 'M1');

    final maxLen = language == 'ko' ? 120 : 300;
    final chunks = _chunkText(text, maxLen: maxLen);
    final langList = List.filled(chunks.length, language);
    List<double>? wavCat;
    double durCat = 0;

    for (var i = 0; i < chunks.length; i++) {
      final result = await _infer(
        [chunks[i]],
        [langList[i]],
        style,
        effectiveConfig.denoisingSteps,
        speed: effectiveConfig.speechSpeed,
      );

      final wav = _safeCast<double>(result['wav']);
      final duration = _safeCast<double>(result['duration']);

      if (wavCat == null) {
        wavCat = wav;
        durCat = duration[0];
      } else {
        wavCat = [
          ...wavCat,
          ...List<double>.filled(
              (effectiveConfig.silenceDuration * sampleRate).floor(), 0.0),
          ...wav
        ];
        durCat += duration[0] + effectiveConfig.silenceDuration;
      }
    }

    return TTSResult(
      audioData: Float64List.fromList(wavCat!),
      sampleRate: sampleRate,
      duration: durCat,
    );
  }

  Future<_Style> _loadStyle(String voiceStyle) async {
    if (_styleCache.containsKey(voiceStyle)) {
      return _styleCache[voiceStyle]!;
    }

    final path = 'assets/voice_styles/$voiceStyle.json';
    final json = jsonDecode(await rootBundle.loadString(path));

    final ttlDims = List<int>.from(json['style_ttl']['dims']);
    final dpDims = List<int>.from(json['style_dp']['dims']);

    final ttlData = _flattenToDouble(json['style_ttl']['data']);
    final dpData = _flattenToDouble(json['style_dp']['data']);

    final ttlFlat = Float32List.fromList(ttlData);
    final dpFlat = Float32List.fromList(dpData);

    final ttlShape = [1, ttlDims[1], ttlDims[2]];
    final dpShape = [1, dpDims[1], dpDims[2]];

    final style = _Style(
      await OrtValue.fromList(ttlFlat, ttlShape),
      await OrtValue.fromList(dpFlat, dpShape),
      ttlShape,
      dpShape,
    );

    _styleCache[voiceStyle] = style;
    return style;
  }

  Future<Map<String, dynamic>> _infer(
    List<String> textList,
    List<String> langList,
    _Style style,
    int totalStep, {
    double speed = 1.05,
  }) async {
    final bsz = textList.length;
    final result = _textProcessor!.call(textList, langList);

    final textIdsRaw = result['textIds'];
    final textIds = textIdsRaw is List<List<int>>
        ? textIdsRaw
        : (textIdsRaw as List).map((row) => (row as List).cast<int>()).toList();

    final textMaskRaw = result['textMask'];
    final textMask = textMaskRaw is List<List<List<double>>>
        ? textMaskRaw
        : (textMaskRaw as List)
            .map((batch) => (batch as List)
                .map((row) => (row as List).cast<double>())
                .toList())
            .toList();

    final textIdsShape = [bsz, textIds[0].length];
    final textMaskShape = [bsz, 1, textMask[0][0].length];
    final textMaskTensor = await _toTensor(textMask, textMaskShape);

    final dpResult = await _dpOrt!.run({
      'text_ids': await _intToTensor(textIds, textIdsShape),
      'style_dp': style.dp,
      'text_mask': textMaskTensor,
    });
    final durOnnx = _safeCast<double>(await dpResult.values.first.asList());
    final scaledDur = durOnnx.map((d) => d / speed).toList();

    final textEncResult = await _textEncOrt!.run({
      'text_ids': await _intToTensor(textIds, textIdsShape),
      'style_ttl': style.ttl,
      'text_mask': textMaskTensor,
    });

    final latentData = _sampleNoisyLatent(scaledDur);
    final noisyLatentRaw = latentData['noisyLatent'];
    var noisyLatent = noisyLatentRaw is List<List<List<double>>>
        ? noisyLatentRaw
        : (noisyLatentRaw as List)
            .map((batch) => (batch as List)
                .map((row) => (row as List).cast<double>())
                .toList())
            .toList();

    final latentMaskRaw = latentData['latentMask'];
    final latentMask = latentMaskRaw is List<List<List<double>>>
        ? latentMaskRaw
        : (latentMaskRaw as List)
            .map((batch) => (batch as List)
                .map((row) => (row as List).cast<double>())
                .toList())
            .toList();

    final latentShape = [bsz, noisyLatent[0].length, noisyLatent[0][0].length];
    final latentMaskTensor =
        await _toTensor(latentMask, [bsz, 1, latentMask[0][0].length]);

    final totalStepTensor =
        await _scalarToTensor(List.filled(bsz, totalStep.toDouble()), [bsz]);

    // Denoising loop
    for (var step = 0; step < totalStep; step++) {
      final result = await _vectorEstOrt!.run({
        'noisy_latent': await _toTensor(noisyLatent, latentShape),
        'text_emb': textEncResult.values.first,
        'style_ttl': style.ttl,
        'text_mask': textMaskTensor,
        'latent_mask': latentMaskTensor,
        'total_step': totalStepTensor,
        'current_step':
            await _scalarToTensor(List.filled(bsz, step.toDouble()), [bsz]),
      });

      final denoisedRaw = await result.values.first.asList();
      final denoised = denoisedRaw is List<double>
          ? denoisedRaw
          : _safeCast<double>(denoisedRaw);
      var idx = 0;
      for (var b = 0; b < noisyLatent.length; b++) {
        for (var d = 0; d < noisyLatent[b].length; d++) {
          for (var t = 0; t < noisyLatent[b][d].length; t++) {
            noisyLatent[b][d][t] = denoised[idx++];
          }
        }
      }
    }

    final vocoderResult = await _vocoderOrt!
        .run({'latent': await _toTensor(noisyLatent, latentShape)});
    final wavRaw = await vocoderResult.values.first.asList();
    final wav = wavRaw is List<double> ? wavRaw : _safeCast<double>(wavRaw);

    return {'wav': wav, 'duration': scaledDur};
  }

  Map<String, dynamic> _sampleNoisyLatent(List<double> duration) {
    final wavLenMax = duration.reduce(math.max) * sampleRate;
    final wavLengths = duration.map((d) => (d * sampleRate).floor()).toList();
    final chunkSize = baseChunkSize * chunkCompressFactor;
    final latentLen = ((wavLenMax + chunkSize - 1) / chunkSize).floor();
    final latentDim = ldim * chunkCompressFactor;

    final random = math.Random();
    final noisyLatent = List.generate(
      duration.length,
      (_) => List.generate(
        latentDim,
        (_) => List.generate(latentLen, (_) {
          final u1 = math.max(1e-10, random.nextDouble());
          final u2 = random.nextDouble();
          return math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
        }),
      ),
    );

    final latentMask = _getLatentMask(wavLengths);

    for (var b = 0; b < noisyLatent.length; b++) {
      for (var d = 0; d < noisyLatent[b].length; d++) {
        for (var t = 0; t < noisyLatent[b][d].length; t++) {
          noisyLatent[b][d][t] *= latentMask[b][0][t];
        }
      }
    }

    return {'noisyLatent': noisyLatent, 'latentMask': latentMask};
  }

  List<List<List<double>>> _getLatentMask(List<int> wavLengths) {
    final latentSize = baseChunkSize * chunkCompressFactor;
    final latentLengths = wavLengths
        .map((len) => ((len + latentSize - 1) / latentSize).floor())
        .toList();
    final maxLen = latentLengths.reduce(math.max);
    return latentLengths
        .map((len) => [List.generate(maxLen, (i) => i < len ? 1.0 : 0.0)])
        .toList();
  }

  List<String> _chunkText(String text, {int maxLen = 300}) {
    final paragraphs = text
        .trim()
        .split(RegExp(r'\n\s*\n+'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    final chunks = <String>[];
    for (var paragraph in paragraphs) {
      paragraph = paragraph.trim();
      if (paragraph.isEmpty) continue;

      final sentences = paragraph.split(RegExp(
          r'(?<!Mr\.|Mrs\.|Ms\.|Dr\.|Prof\.)(?<!\b[A-Z]\.)(?<=[.!?])\s+'));

      var currentChunk = '';
      for (final sentence in sentences) {
        if (currentChunk.length + sentence.length + 1 <= maxLen) {
          currentChunk += (currentChunk.isNotEmpty ? ' ' : '') + sentence;
        } else {
          if (currentChunk.isNotEmpty) chunks.add(currentChunk.trim());
          currentChunk = sentence;
        }
      }
      if (currentChunk.isNotEmpty) chunks.add(currentChunk.trim());
    }

    return chunks;
  }

  List<T> _safeCast<T>(dynamic raw) {
    if (raw is List<T>) return raw;
    if (raw is List) {
      if (raw.isNotEmpty && raw.first is List) {
        return _flattenList<T>(raw);
      }
      if (T == double) {
        return raw
            .map((e) => e is num ? e.toDouble() : double.parse(e.toString()))
            .toList() as List<T>;
      }
      return raw.cast<T>();
    }
    throw Exception('Cannot convert $raw to List<$T>');
  }

  List<T> _flattenList<T>(dynamic list) {
    if (list is List) {
      return list.expand((e) => _flattenList<T>(e)).toList();
    }
    if (T == double && list is num) {
      return [list.toDouble()] as List<T>;
    }
    return [list as T];
  }

  Future<OrtValue> _toTensor(dynamic array, List<int> dims) async {
    final flat = _flattenList<double>(array);
    return await OrtValue.fromList(Float32List.fromList(flat), dims);
  }

  Future<OrtValue> _scalarToTensor(List<double> array, List<int> dims) async {
    return await OrtValue.fromList(Float32List.fromList(array), dims);
  }

  Future<OrtValue> _intToTensor(List<List<int>> array, List<int> dims) async {
    final flat = array.expand((row) => row).toList();
    return await OrtValue.fromList(Int64List.fromList(flat), dims);
  }

  Future<Map<String, dynamic>> _loadCfgs(String onnxDir) async {
    final path = '$onnxDir/tts.json';
    final json = jsonDecode(await rootBundle.loadString(path));
    return json as Map<String, dynamic>;
  }

  Future<String> _copyModelToFile(String path) async {
    final byteData = await rootBundle.load(path);
    final tempDir = await getApplicationCacheDirectory();
    final modelPath = '${tempDir.path}/${path.split("/").last}';

    final file = File(modelPath);
    if (!file.existsSync()) {
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
    return modelPath;
  }

  Future<Map<String, OrtSession>> _loadOnnxAll(String dir) async {
    final ort = OnnxRuntime();
    final models = [
      'duration_predictor',
      'text_encoder',
      'vector_estimator',
      'vocoder'
    ];

    final sessions = await Future.wait(models.map((name) async {
      final path = await _copyModelToFile('$dir/$name.onnx');
      _logger.d('Loading $name.onnx');
      return ort.createSessionFromAsset(path);
    }));

    return {
      'dpOrt': sessions[0],
      'textEncOrt': sessions[1],
      'vectorEstOrt': sessions[2],
      'vocoderOrt': sessions[3],
    };
  }

  List<double> _flattenToDouble(dynamic list) {
    if (list is List) return list.expand((e) => _flattenToDouble(e)).toList();
    return [list is num ? list.toDouble() : double.parse(list.toString())];
  }

  /// Releases all resources and resets the TTS engine.
  ///
  /// Call this method when you're done using the TTS engine to free up memory
  /// and resources. After calling [dispose], you must call [initialize] again
  /// before using the engine.
  ///
  /// Example:
  /// ```dart
  /// final tts = SupertonicTTS();
  /// await tts.initialize();
  ///
  /// // Use the TTS engine
  /// await tts.synthesize('Hello', language: 'en');
  ///
  /// // Clean up when done
  /// tts.dispose();
  ///
  /// // Can reinitialize if needed
  /// await tts.initialize();
  /// ```
  ///
  /// Note: This method is safe to call multiple times.
  void dispose() {
    _dpOrt = null;
    _textEncOrt = null;
    _vectorEstOrt = null;
    _vocoderOrt = null;
    _styleCache.clear();
    _isInitialized = false;
  }
}
