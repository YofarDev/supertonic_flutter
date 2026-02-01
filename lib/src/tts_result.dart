import 'dart:typed_data';

/// Result of text-to-speech synthesis containing the generated audio data.
///
/// This class encapsulates the raw audio output from [SupertonicTTS.synthesize],
/// including the audio samples, sample rate, and duration.
///
/// Example:
/// ```dart
/// final result = await tts.synthesize('Hello world!', language: 'en');
///
/// // Get information about the result
/// print(result.duration);     // 2.5 seconds
/// print(result.sampleRate);   // 24000 Hz
/// print(result.audioData.length); // Number of samples
///
/// // Convert to WAV and save
/// final wavBytes = result.toWavBytes();
/// await File('output.wav').writeAsBytes(wavBytes);
///
/// // Or play directly
/// await player.play(result);
/// ```
///
/// See also:
/// - [TTSAudioPlayer.play] for playing the result
/// - [toWavBytes] for exporting to WAV format
class TTSResult {
  /// Raw audio data as floating point samples ranging from -1.0 to 1.0.
  ///
  /// This is the raw audio output from the TTS model. Each value represents
  /// one audio sample. To convert to a playable format, use [toWavBytes].
  ///
  /// Example:
  /// ```dart
  /// // Access raw samples
  /// for (var i = 0; i < result.audioData.length; i++) {
  ///   final sample = result.audioData[i];
  ///   // Process sample...
  /// }
  /// ```
  final Float64List audioData;

  /// Sample rate in Hz (typically 24000).
  ///
  /// This is the number of audio samples per second. Higher sample rates
  /// generally provide better audio quality but larger file sizes.
  ///
  /// Example:
  /// ```dart
  /// if (result.sampleRate == 24000) {
  ///   print('Standard sample rate');
  /// }
  /// ```
  final int sampleRate;

  /// Duration of the audio in seconds.
  ///
  /// Represents the total length of the synthesized audio.
  ///
  /// Example:
  /// ```dart
  /// print('Audio length: ${result.duration}s');
  /// // Output: Audio length: 2.35s
  /// ```
  final double duration;

  /// Creates a new TTS result.
  ///
  /// All parameters are required.
  ///
  /// Example:
  /// ```dart
  /// final result = TTSResult(
  ///   audioData: Float64List.fromList([0.1, -0.2, 0.3, ...]),
  ///   sampleRate: 24000,
  ///   duration: 1.5,
  /// );
  /// ```
  const TTSResult({
    required this.audioData,
    required this.sampleRate,
    required this.duration,
  });

  /// Converts the audio data to 16-bit PCM WAV format bytes.
  ///
  /// This method creates a standard WAV file header and converts the floating
  /// point samples to 16-bit PCM format. The resulting bytes can be written
  /// to a file or used for playback.
  ///
  /// The WAV file will have the following properties:
  /// - Format: 16-bit PCM
  /// - Channels: Mono (1 channel)
  /// - Sample rate: As specified in [sampleRate]
  ///
  /// Example:
  /// ```dart
  /// // Save to file
  /// final wavBytes = result.toWavBytes();
  /// final file = File('output.wav');
  /// await file.writeAsBytes(wavBytes);
  ///
  /// // Or use directly
  /// final wavBytes = result.toWavBytes();
  /// await player.setUrl(Uri.file('output.wav').toString());
  /// ```
  ///
  /// Returns a [Uint8List] containing the complete WAV file data including header.
  Uint8List toWavBytes() {
    const numChannels = 1;
    const bitsPerSample = 16;
    final dataSize = audioData.length * 2;

    final buffer = ByteData(44 + dataSize);
    var offset = 0;

    // RIFF header
    for (var byte in [0x52, 0x49, 0x46, 0x46]) {
      buffer.setUint8(offset++, byte);
    }
    buffer.setUint32(offset, 36 + dataSize, Endian.little);
    offset += 4;

    // WAVE
    for (var byte in [0x57, 0x41, 0x56, 0x45]) {
      buffer.setUint8(offset++, byte);
    }

    // fmt chunk
    for (var byte in [0x66, 0x6D, 0x74, 0x20]) {
      buffer.setUint8(offset++, byte);
    }
    buffer.setUint32(offset, 16, Endian.little);
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little); // Audio format (PCM)
    offset += 2;
    buffer.setUint16(offset, numChannels, Endian.little);
    offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    buffer.setUint32(offset, sampleRate * numChannels * 2, Endian.little);
    offset += 4;
    buffer.setUint16(offset, numChannels * 2, Endian.little);
    offset += 2;
    buffer.setUint16(offset, bitsPerSample, Endian.little);
    offset += 2;

    // data chunk
    for (var byte in [0x64, 0x61, 0x74, 0x61]) {
      buffer.setUint8(offset++, byte);
    }
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    // Write audio samples
    for (var i = 0; i < audioData.length; i++) {
      final sample = (audioData[i].clamp(-1.0, 1.0) * 32767).round();
      buffer.setInt16(offset + i * 2, sample, Endian.little);
    }

    return buffer.buffer.asUint8List();
  }

  @override
  String toString() {
    return 'TTSResult(duration: ${duration.toStringAsFixed(2)}s, sampleRate: ${sampleRate}Hz, samples: ${audioData.length})';
  }
}
