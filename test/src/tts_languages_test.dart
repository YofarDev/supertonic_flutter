import 'package:flutter_test/flutter_test.dart';
import 'package:supertonic_flutter/src/tts_languages.dart';

void main() {
  group('TTSLanguage', () {
    test('all contains 31 languages plus language-agnostic mode', () {
      expect(TTSLanguage.all.length, 32);
    });

    test('all has expected language codes', () {
      final codes = TTSLanguage.all.map((l) => l.code).toList();
      expect(
        codes,
        containsAll([
          'en', 'ko', 'ja', 'ar', 'bg', 'cs', 'da', 'de', 'el', 'es', 'et', //
          'fi', 'fr', 'hi', 'hr', 'hu', 'id', 'it', 'lt', 'lv', 'nl', 'pl',
          'pt', 'ro', 'ru', 'sk', 'sl', 'sv', 'tr', 'uk', 'vi', 'na',
        ]),
      );
    });

    test('all has no duplicate codes', () {
      final codes = TTSLanguage.all.map((l) => l.code).toList();
      expect(codes.toSet().length, codes.length);
    });

    group('static constants', () {
      test('english', () {
        expect(TTSLanguage.english.code, 'en');
        expect(TTSLanguage.english.name, 'English');
        expect(TTSLanguage.english.nativeName, 'English');
      });

      test('korean', () {
        expect(TTSLanguage.korean.code, 'ko');
        expect(TTSLanguage.korean.name, 'Korean');
        expect(TTSLanguage.korean.nativeName, '한국어');
      });

      test('spanish', () {
        expect(TTSLanguage.spanish.code, 'es');
        expect(TTSLanguage.spanish.name, 'Spanish');
        expect(TTSLanguage.spanish.nativeName, 'Español');
      });

      test('portuguese', () {
        expect(TTSLanguage.portuguese.code, 'pt');
        expect(TTSLanguage.portuguese.name, 'Portuguese');
        expect(TTSLanguage.portuguese.nativeName, 'Português');
      });

      test('french', () {
        expect(TTSLanguage.french.code, 'fr');
        expect(TTSLanguage.french.name, 'French');
        expect(TTSLanguage.french.nativeName, 'Français');
      });

      test('japanese', () {
        expect(TTSLanguage.japanese.code, 'ja');
        expect(TTSLanguage.japanese.name, 'Japanese');
        expect(TTSLanguage.japanese.nativeName, '日本語');
      });

      test('german', () {
        expect(TTSLanguage.german.code, 'de');
        expect(TTSLanguage.german.name, 'German');
        expect(TTSLanguage.german.nativeName, 'Deutsch');
      });

      test('languageAgnostic', () {
        expect(TTSLanguage.languageAgnostic.code, 'na');
        expect(TTSLanguage.languageAgnostic.name, 'Language-agnostic');
        expect(TTSLanguage.languageAgnostic.nativeName, 'Auto');
      });
    });

    group('fromCode', () {
      test('returns correct language for each code', () {
        expect(TTSLanguage.fromCode('en'), same(TTSLanguage.english));
        expect(TTSLanguage.fromCode('ko'), same(TTSLanguage.korean));
        expect(TTSLanguage.fromCode('es'), same(TTSLanguage.spanish));
        expect(TTSLanguage.fromCode('pt'), same(TTSLanguage.portuguese));
        expect(TTSLanguage.fromCode('fr'), same(TTSLanguage.french));
        expect(TTSLanguage.fromCode('ja'), same(TTSLanguage.japanese));
        expect(TTSLanguage.fromCode('de'), same(TTSLanguage.german));
        expect(TTSLanguage.fromCode('na'), same(TTSLanguage.languageAgnostic));
      });

      test('returns english for unknown code', () {
        expect(TTSLanguage.fromCode('xx'), same(TTSLanguage.english));
        expect(TTSLanguage.fromCode(''), same(TTSLanguage.english));
        expect(TTSLanguage.fromCode('EN'), same(TTSLanguage.english));
      });
    });

    test('toString returns code', () {
      expect(TTSLanguage.english.toString(), 'en');
      expect(TTSLanguage.korean.toString(), 'ko');
    });
  });

  group('TTSTestStrings', () {
    group('forLanguage', () {
      test('returns non-empty string for each supported language', () {
        for (final lang in TTSLanguage.all) {
          final text = TTSTestStrings.forLanguage(lang.code);
          expect(text.isNotEmpty, isTrue, reason: 'Empty for ${lang.code}');
        }
      });

      test('returns english fallback for unknown code', () {
        final result = TTSTestStrings.forLanguage('zz');
        expect(result, TTSTestStrings.forLanguage('en'));
      });

      test('english contains "Supertonic"', () {
        expect(TTSTestStrings.forLanguage('en'), contains('Supertonic'));
      });
    });

    group('shortForLanguage', () {
      test('returns non-empty short string for each language', () {
        for (final lang in TTSLanguage.all) {
          final text = TTSTestStrings.shortForLanguage(lang.code);
          expect(text.isNotEmpty, isTrue, reason: 'Empty for ${lang.code}');
        }
      });

      test('short string is no longer than full string', () {
        // Languages without a dedicated full string fall back to the short
        // string, so the two may be equal.
        for (final lang in TTSLanguage.all) {
          final short = TTSTestStrings.shortForLanguage(lang.code);
          final full = TTSTestStrings.forLanguage(lang.code);
          expect(short.length, lessThanOrEqualTo(full.length),
              reason: lang.code);
        }
      });

      test('returns english fallback for unknown code', () {
        final result = TTSTestStrings.shortForLanguage('zz');
        expect(result, TTSTestStrings.shortForLanguage('en'));
      });
    });
  });
}
