import 'package:flutter_test/flutter_test.dart';
import 'package:supertonic_flutter/src/tts_voices.dart';

void main() {
  group('TTSVoiceStyle', () {
    test('all contains exactly 10 voices', () {
      expect(TTSVoiceStyle.all.length, 10);
    });

    test('all has 5 male and 5 female codes', () {
      final male = TTSVoiceStyle.all.keys.where((k) => k.startsWith('M'));
      final female = TTSVoiceStyle.all.keys.where((k) => k.startsWith('F'));
      expect(male.length, 5);
      expect(female.length, 5);
    });

    test('every voice has non-empty code, description, useCases', () {
      for (final voice in TTSVoiceStyle.all.values) {
        expect(voice.code.isNotEmpty, isTrue);
        expect(voice.description.isNotEmpty, isTrue);
        expect(voice.useCases.isNotEmpty, isTrue);
      }
    });

    test('map keys match voice codes', () {
      for (final entry in TTSVoiceStyle.all.entries) {
        expect(entry.key, entry.value.code);
      }
    });

    group('static constants', () {
      test('male voices M1-M5', () {
        expect(TTSVoiceStyle.m1.code, 'M1');
        expect(TTSVoiceStyle.m2.code, 'M2');
        expect(TTSVoiceStyle.m3.code, 'M3');
        expect(TTSVoiceStyle.m4.code, 'M4');
        expect(TTSVoiceStyle.m5.code, 'M5');
      });

      test('female voices F1-F5', () {
        expect(TTSVoiceStyle.f1.code, 'F1');
        expect(TTSVoiceStyle.f2.code, 'F2');
        expect(TTSVoiceStyle.f3.code, 'F3');
        expect(TTSVoiceStyle.f4.code, 'F4');
        expect(TTSVoiceStyle.f5.code, 'F5');
      });

      test('static constants match all map values', () {
        expect(TTSVoiceStyle.all['M1'], same(TTSVoiceStyle.m1));
        expect(TTSVoiceStyle.all['M2'], same(TTSVoiceStyle.m2));
        expect(TTSVoiceStyle.all['M3'], same(TTSVoiceStyle.m3));
        expect(TTSVoiceStyle.all['M4'], same(TTSVoiceStyle.m4));
        expect(TTSVoiceStyle.all['M5'], same(TTSVoiceStyle.m5));
        expect(TTSVoiceStyle.all['F1'], same(TTSVoiceStyle.f1));
        expect(TTSVoiceStyle.all['F2'], same(TTSVoiceStyle.f2));
        expect(TTSVoiceStyle.all['F3'], same(TTSVoiceStyle.f3));
        expect(TTSVoiceStyle.all['F4'], same(TTSVoiceStyle.f4));
        expect(TTSVoiceStyle.all['F5'], same(TTSVoiceStyle.f5));
      });
    });

    group('fromCode', () {
      test('returns correct voice for each code', () {
        for (final entry in TTSVoiceStyle.all.entries) {
          expect(TTSVoiceStyle.fromCode(entry.key), same(entry.value));
        }
      });

      test('returns M1 for unknown code', () {
        expect(TTSVoiceStyle.fromCode('X1'), same(TTSVoiceStyle.m1));
        expect(TTSVoiceStyle.fromCode(''), same(TTSVoiceStyle.m1));
        expect(TTSVoiceStyle.fromCode('m1'), same(TTSVoiceStyle.m1));
      });
    });

    test('toString returns code', () {
      expect(TTSVoiceStyle.m1.toString(), 'M1');
      expect(TTSVoiceStyle.f3.toString(), 'F3');
    });
  });
}
