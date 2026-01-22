import 'dart:typed_data';

/// Result of text-to-speech synthesis
class TTSResult {
  /// Raw audio data as floating point samples (-1.0 to 1.0)
  final Float64List audioData;

  /// Sample rate in Hz (typically 24000)
  final int sampleRate;

  /// Duration of the audio in seconds
  final double duration;

  const TTSResult({
    required this.audioData,
    required this.sampleRate,
    required this.duration,
  });

  /// Convert audio data to 16-bit PCM WAV format bytes
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
