import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:supertonic_flutter/src/tts_result.dart';

void main() {
  group('TTSResult', () {
    TTSResult makeResult({
      List<double> samples = const [0.0, 0.5, -0.5, 1.0, -1.0],
      int sampleRate = 24000,
      double duration = 1.0,
    }) {
      return TTSResult(
        audioData: Float64List.fromList(samples),
        sampleRate: sampleRate,
        duration: duration,
      );
    }

    test('stores fields', () {
      final result = makeResult();
      expect(result.sampleRate, 24000);
      expect(result.duration, 1.0);
      expect(result.audioData.length, 5);
    });

    group('toWavBytes', () {
      test('produces valid RIFF header', () {
        final result = makeResult();
        final bytes = result.toWavBytes();

        // RIFF magic
        expect(bytes[0], 0x52); // R
        expect(bytes[1], 0x49); // I
        expect(bytes[2], 0x46); // F
        expect(bytes[3], 0x46); // F

        // WAVE magic at offset 8
        expect(bytes[8], 0x57); // W
        expect(bytes[9], 0x41); // A
        expect(bytes[10], 0x56); // V
        expect(bytes[11], 0x45); // E
      });

      test('fmt chunk is PCM mono 16-bit', () {
        final result = makeResult(sampleRate: 22050);
        final bytes = result.toWavBytes();
        final buf = bytes.buffer.asByteData();

        // fmt chunk at offset 12
        // chunk size = 16
        expect(buf.getUint32(16, Endian.little), 16);
        // audio format = 1 (PCM)
        expect(buf.getUint16(20, Endian.little), 1);
        // channels = 1
        expect(buf.getUint16(22, Endian.little), 1);
        // sample rate
        expect(buf.getUint32(24, Endian.little), 22050);
        // bits per sample = 16
        expect(buf.getUint16(34, Endian.little), 16);
      });

      test('total size = 44 header + 2 bytes per sample', () {
        final samples = List<double>.filled(100, 0.0);
        final result = makeResult(samples: samples);
        final bytes = result.toWavBytes();
        expect(bytes.length, 44 + 100 * 2);
      });

      test('clamps samples to [-1, 1] before conversion', () {
        final result = makeResult(samples: [2.0, -2.0]);
        final bytes = result.toWavBytes();
        final buf = bytes.buffer.asByteData();

        // +2.0 clamped to 1.0 → 32767
        expect(buf.getInt16(44, Endian.little), 32767);
        // -2.0 clamped to -1.0 → -32767
        expect(buf.getInt16(46, Endian.little), -32767);
      });

      test('zero samples produce zero PCM', () {
        final result = makeResult(samples: [0.0]);
        final bytes = result.toWavBytes();
        final buf = bytes.buffer.asByteData();
        expect(buf.getInt16(44, Endian.little), 0);
      });

      test('full-scale positive sample maps to 32767', () {
        final result = makeResult(samples: [1.0]);
        final bytes = result.toWavBytes();
        final buf = bytes.buffer.asByteData();
        expect(buf.getInt16(44, Endian.little), 32767);
      });

      test('full-scale negative sample maps to -32767', () {
        final result = makeResult(samples: [-1.0]);
        final bytes = result.toWavBytes();
        final buf = bytes.buffer.asByteData();
        expect(buf.getInt16(44, Endian.little), -32767);
      });

      test('data chunk header is correct', () {
        final result = makeResult(samples: [0.1, 0.2, 0.3]);
        final bytes = result.toWavBytes();

        // "data" at offset 36
        expect(bytes[36], 0x64); // d
        expect(bytes[37], 0x61); // a
        expect(bytes[38], 0x74); // t
        expect(bytes[39], 0x61); // a

        // data size = 3 samples * 2 bytes
        final buf = bytes.buffer.asByteData();
        expect(buf.getUint32(40, Endian.little), 6);
      });

      test('RIFF file size field is correct', () {
        final result = makeResult(samples: List.filled(50, 0.0));
        final bytes = result.toWavBytes();
        final buf = bytes.buffer.asByteData();

        // file size = total bytes - 8 (RIFF header)
        expect(buf.getUint32(4, Endian.little), bytes.length - 8);
      });
    });

    test('toString contains duration, sampleRate, and sample count', () {
      final result = makeResult(duration: 2.5);
      final str = result.toString();
      expect(str, contains('2.50'));
      expect(str, contains('24000'));
      expect(str, contains('5'));
    });
  });
}
