import 'package:flutter_test/flutter_test.dart';
import 'package:supertonic_flutter/src/tts_config.dart';

void main() {
  group('TTSConfig', () {
    test('defaults', () {
      const config = TTSConfig();
      expect(config.denoisingSteps, 5);
      expect(config.speechSpeed, 1.05);
      expect(config.silenceDuration, 0.3);
    });

    test('custom values', () {
      const config = TTSConfig(
        denoisingSteps: 10,
        speechSpeed: 1.5,
        silenceDuration: 0.8,
      );
      expect(config.denoisingSteps, 10);
      expect(config.speechSpeed, 1.5);
      expect(config.silenceDuration, 0.8);
    });

    test('copyWith overrides specified fields', () {
      const config = TTSConfig();
      final copy = config.copyWith(denoisingSteps: 15);
      expect(copy.denoisingSteps, 15);
      expect(copy.speechSpeed, 1.05);
      expect(copy.silenceDuration, 0.3);
    });

    test('copyWith preserves all fields when no args', () {
      const config = TTSConfig(
        denoisingSteps: 3,
        speechSpeed: 0.75,
        silenceDuration: 0.5,
      );
      final copy = config.copyWith();
      expect(copy.denoisingSteps, 3);
      expect(copy.speechSpeed, 0.75);
      expect(copy.silenceDuration, 0.5);
    });

    test('copyWith can override multiple fields', () {
      const config = TTSConfig();
      final copy = config.copyWith(
        denoisingSteps: 20,
        speechSpeed: 2.0,
        silenceDuration: 1.5,
      );
      expect(copy.denoisingSteps, 20);
      expect(copy.speechSpeed, 2.0);
      expect(copy.silenceDuration, 1.5);
    });

    test('toString contains all fields', () {
      const config = TTSConfig();
      final str = config.toString();
      expect(str, contains('5'));
      expect(str, contains('1.05'));
      expect(str, contains('0.3'));
    });

    test('is const-constructible', () {
      // Verify it compiles as const
      const config = TTSConfig(denoisingSteps: 1);
      expect(config.denoisingSteps, 1);
    });
  });
}
