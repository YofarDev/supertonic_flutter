import 'package:flutter_test/flutter_test.dart';
import 'package:supertonic_flutter/src/supertonic_tts.dart';

void main() {
  group('SupertonicTTS', () {
    late SupertonicTTS tts;

    setUp(() {
      tts = SupertonicTTS();
    });

    tearDown(() {
      tts.dispose();
    });

    test('isInitialized is false by default', () {
      expect(tts.isInitialized, isFalse);
    });

    test('sampleRate defaults to 24000', () {
      expect(tts.sampleRate, 24000);
    });

    test('baseChunkSize defaults to 512', () {
      expect(tts.baseChunkSize, 512);
    });

    test('chunkCompressFactor defaults to 2', () {
      expect(tts.chunkCompressFactor, 2);
    });

    test('ldim defaults to 512', () {
      expect(tts.ldim, 512);
    });

    test('synthesize throws StateError when not initialized', () async {
      expect(
        () => tts.synthesize('Hello'),
        throwsA(isA<StateError>()),
      );
    });

    test('dispose resets isInitialized to false', () {
      tts.dispose();
      expect(tts.isInitialized, isFalse);
    });

    test('dispose is safe to call multiple times', () {
      tts.dispose();
      tts.dispose();
      expect(tts.isInitialized, isFalse);
    });
  });

  group('chunkText', () {
    late SupertonicTTS tts;

    setUp(() {
      tts = SupertonicTTS();
    });

    tearDown(() {
      tts.dispose();
    });

    test('single short text returns one chunk', () {
      final chunks = tts.chunkText('Hello world.');
      expect(chunks, ['Hello world.']);
    });

    test('splits on sentence boundaries when over maxLen', () {
      final a = 'A' * 150;
      final b = 'B' * 150;
      final c = 'C' * 150;
      final chunks = tts.chunkText('$a. $b. $c.', maxLen: 200);
      expect(chunks.length, 3);
    });

    test('merges short sentences within maxLen', () {
      final text = 'Hi. Bye.';
      final chunks = tts.chunkText(text, maxLen: 100);
      expect(chunks.length, 1);
    });

    test('splits when sentence exceeds maxLen', () {
      final long = 'A' * 200;
      final text = '$long. $long.';
      final chunks = tts.chunkText(text, maxLen: 250);
      expect(chunks.length, 2);
    });

    test('splits on paragraph breaks (double newline)', () {
      final chunks = tts.chunkText('Para one.\n\nPara two.');
      expect(chunks.length, 2);
      expect(chunks[0], 'Para one.');
      expect(chunks[1], 'Para two.');
    });

    test('trims whitespace from chunks', () {
      final chunks = tts.chunkText('  Hello.  ');
      expect(chunks, ['Hello.']);
    });

    test('empty string returns empty list', () {
      final chunks = tts.chunkText('');
      expect(chunks, isEmpty);
    });

    test('whitespace-only string returns empty list', () {
      final chunks = tts.chunkText('   \n\n   ');
      expect(chunks, isEmpty);
    });

    test(
        'splits Hindi text on danda (।) instead of treating it as one unbounded sentence',
        () {
      const sentence =
          'यह एक लंबा हिंदी वाक्य है जो परीक्षण के लिए बार-बार दोहराया जाता है';
      final paragraph = '${List.filled(6, sentence).join('। ')}।';

      final chunks = tts.chunkText(paragraph, maxLen: 300);

      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(300));
      }
    });

    test('splits CJK fullwidth-punctuated text correctly', () {
      const sentence = 'これはテストのための長い日本語の文章です';
      final paragraph = '${List.filled(6, sentence).join('。')}。';

      final chunks = tts.chunkText(paragraph, maxLen: 120);

      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(120));
      }
    });

    test('splits Japanese at 。 even without a following space', () {
      final chunks = tts.chunkText('おはよう。こんにちは。さようなら。', maxLen: 10);

      expect(chunks.length, 3);
      expect(chunks[0], 'おはよう。');
      expect(chunks[1], 'こんにちは。');
      expect(chunks[2], 'さようなら。');
    });

    test('splits Hindi at danda (।) even without a following space', () {
      final chunks =
          tts.chunkText('यह पहला वाक्य है।यह दूसरा वाक्य है।', maxLen: 20);

      expect(chunks.length, 2);
      expect(chunks[0], 'यह पहला वाक्य है।');
      expect(chunks[1], 'यह दूसरा वाक्य है।');
    });

    test('does not split ASCII punctuation zero-width (decimals stay intact)',
        () {
      final chunks = tts.chunkText('Pi is 3.14 rounded. Euler is 2.72.');

      expect(chunks, ['Pi is 3.14 rounded. Euler is 2.72.']);
    });

    test('splits Arabic question-mark-punctuated text correctly', () {
      const sentence = 'هل هذه جملة طويلة لأغراض الاختبار فقط';
      final paragraph = '${List.filled(6, sentence).join('؟ ')}؟';

      final chunks = tts.chunkText(paragraph, maxLen: 150);

      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(150));
      }
    });

    test(
        'hard-caps a single sentence that exceeds maxLen with no recognized punctuation at all',
        () {
      final noPunctuationOrSpaces = 'अ' * 1000;

      final chunks = tts.chunkText(noPunctuationOrSpaces, maxLen: 300);

      expect(chunks, isNotEmpty);
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(300));
      }
      expect(chunks.join('').length, 1000);
    });

    test('still respects the Mr./Dr. abbreviation lookbehind for English', () {
      final chunks = tts.chunkText('Dr. Smith arrived. He was late.');
      expect(chunks.any((c) => c.trim() == 'Dr'), isFalse);
    });
  });

  group('decomposeHangulSyllable', () {
    test('non-Hangul codepoint returns itself', () {
      expect(decomposeHangulSyllable(0x0041), [0x0041]); // 'A'
    });

    test('가 (GA) decomposes to leading + vowel', () {
      // 가 = 0xAC00, leading=0x1100, vowel=0x1161
      final result = decomposeHangulSyllable(0xAC00);
      expect(result, [0x1100, 0x1161]);
    });

    test('한 (HAN) decomposes to leading + vowel + trailing', () {
      // 한 = 0xD55C
      final result = decomposeHangulSyllable(0xD55C);
      expect(result.length, 3);
      expect(result[0], greaterThanOrEqualTo(0x1100));
      expect(result[1], greaterThanOrEqualTo(0x1161));
      expect(result[2], greaterThanOrEqualTo(0x11A8));
    });

    test('boundary: first syllable 가 (0xAC00)', () {
      final result = decomposeHangulSyllable(0xAC00);
      expect(result.length, 2); // no trailing
    });

    test('boundary: last syllable 힣 (0xD7A3)', () {
      final result = decomposeHangulSyllable(0xD7A3);
      expect(result.length, 3); // has trailing
    });

    test('just below range returns itself', () {
      expect(decomposeHangulSyllable(0xABFF), [0xABFF]);
    });

    test('just above range returns itself', () {
      expect(decomposeHangulSyllable(0xD7A4), [0xD7A4]);
    });
  });

  group('applyNfkdDecomposition', () {
    test('ASCII text unchanged', () {
      expect(applyNfkdDecomposition('Hello'), 'Hello');
    });

    test('decomposes á (a + combining acute)', () {
      final result = applyNfkdDecomposition('á');
      // á = U+00E1 → U+0061 + U+0301
      expect(result.runes.length, 2);
      expect(result.runes.first, 0x0061); // a
    });

    test('decomposes é (e + combining acute)', () {
      final result = applyNfkdDecomposition('é');
      expect(result.runes.length, 2);
      expect(result.runes.first, 0x0065); // e
    });

    test('decomposes ç (c + combining cedilla)', () {
      final result = applyNfkdDecomposition('ç');
      expect(result.runes.length, 2);
      expect(result.runes.first, 0x0063); // c
    });

    test('decomposes ñ (n + combining tilde)', () {
      final result = applyNfkdDecomposition('ñ');
      expect(result.runes.length, 2);
      expect(result.runes.first, 0x006E); // n
    });

    test('decomposes Korean syllable', () {
      final result = applyNfkdDecomposition('한');
      expect(result.runes.length, greaterThan(1));
    });

    test('mixed text preserves non-accented characters', () {
      final result = applyNfkdDecomposition('café');
      expect(result, contains('caf'));
    });

    test('empty string returns empty', () {
      expect(applyNfkdDecomposition(''), '');
    });

    test('decomposes uppercase Á', () {
      final result = applyNfkdDecomposition('Á');
      expect(result.runes.length, 2);
      expect(result.runes.first, 0x0041); // A
    });
  });

  group('preprocessText', () {
    test('wraps text in language tags', () {
      final result = preprocessText('Hello', 'en');
      expect(result, startsWith('<en>'));
      expect(result, endsWith('</en>'));
    });

    test('adds period if missing terminal punctuation', () {
      final result = preprocessText('Hello', 'en');
      expect(result, contains('Hello.'));
    });

    test('does not add period if already has one', () {
      final result = preprocessText('Hello.', 'en');
      expect(result, isNot(contains('..')));
    });

    test('does not add period for exclamation mark', () {
      final result = preprocessText('Hello!', 'en');
      expect(result, contains('Hello!'));
    });

    test('does not add period after Devanagari danda (।)', () {
      final result = preprocessText('यह एक वाक्य है।', 'hi');
      expect(result, isNot(contains('।.')));
    });

    test('does not add period after Arabic question mark (؟)', () {
      final result = preprocessText('هل هذا اختبار؟', 'ar');
      expect(result, isNot(contains('؟.')));
    });

    test('does not add period after fullwidth exclamation (！)', () {
      final result = preprocessText('こんにちは！', 'ja');
      expect(result, isNot(contains('！.')));
    });

    test('removes emojis', () {
      final result = preprocessText('Hello 😀 world', 'en');
      expect(result, isNot(contains('😀')));
    });

    test('replaces @ with " at "', () {
      final result = preprocessText('user@host', 'en');
      expect(result, contains(' at '));
      expect(result, isNot(contains('@')));
    });

    test('replaces en-dash with hyphen', () {
      final result = preprocessText('A–B', 'en');
      expect(result, contains('-'));
    });

    test('replaces curly quotes with straight quotes', () {
      final result = preprocessText('“hello”', 'en');
      expect(result, contains('"'));
    });

    test('collapses multiple spaces', () {
      final result = preprocessText('hello   world', 'en');
      expect(result, isNot(contains('  ')));
    });

    test('replaces e.g., with "for example, "', () {
      final result = preprocessText('e.g., stuff', 'en');
      expect(result, contains('for example,'));
    });

    test('replaces i.e., with "that is, "', () {
      final result = preprocessText('i.e., stuff', 'en');
      expect(result, contains('that is,'));
    });

    test('removes special symbols', () {
      final result = preprocessText('Hello ♥ world', 'en');
      expect(result, isNot(contains('♥')));
    });

    test('korean language tag', () {
      final result = preprocessText('안녕', 'ko');
      expect(result, startsWith('<ko>'));
      expect(result, endsWith('</ko>'));
    });

    test('empty text stays empty with just tags', () {
      final result = preprocessText('', 'en');
      // Empty text after trimming won't get a period added, but still gets tags
      expect(result, contains('<en>'));
    });
  });
}
