/// Supported languages for text-to-speech synthesis.
///
/// Supertonic TTS supports 5 languages with native pronunciation and proper
/// accent handling for each language.
///
/// Supported languages:
/// - English (en) - Standard American English
/// - Korean (ko) - Native Korean with Hangul support
/// - Spanish (es) - Standard Spanish with accent handling
/// - Portuguese (pt) - Brazilian Portuguese with accent support
/// - French (fr) - Standard French with comprehensive accents
///
/// Example:
/// ```dart
/// // Get language info
/// final lang = TTSLanguage.fromCode('en');
/// print(lang.name);       // 'English'
/// print(lang.nativeName); // 'English'
///
/// // List all languages
/// for (final lang in TTSLanguage.all) {
///   print('${lang.code}: ${lang.nativeName}');
/// }
/// ```
///
/// See also:
/// - [TTSTestStrings] for sample text in each language
class TTSLanguage {
  final String code;
  final String name;
  final String nativeName;

  const TTSLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  /// English language - Standard American English pronunciation.
  ///
  /// Code: `en`
  ///
  /// Example:
  /// ```dart
  /// await tts.synthesize('Hello, world!', language: 'en');
  /// ```
  static const english =
      TTSLanguage(code: 'en', name: 'English', nativeName: 'English');

  /// Korean language - Native Korean with Hangul Jamo decomposition.
  ///
  /// Code: `ko`
  ///
  /// Supports proper Korean pronunciation through Hangul syllable decomposition.
  ///
  /// Example:
  /// ```dart
  /// await tts.synthesize('안녕하세요', language: 'ko');
  /// ```
  static const korean =
      TTSLanguage(code: 'ko', name: 'Korean', nativeName: '한국어');

  /// Spanish language - Standard Spanish with accent handling.
  ///
  /// Code: `es`
  ///
  /// Handles accented characters: á, é, í, ó, ú, ñ, ü
  ///
  /// Example:
  /// ```dart
  /// await tts.synthesize('¡Hola, mundo!', language: 'es');
  /// ```
  static const spanish =
      TTSLanguage(code: 'es', name: 'Spanish', nativeName: 'Español');

  /// Portuguese language - Brazilian Portuguese with accent support.
  ///
  /// Code: `pt`
  ///
  /// Handles accented characters: ã, õ, ç, á, é, í, ó, ú
  ///
  /// Example:
  /// ```dart
  /// await tts.synthesize('Olá, mundo!', language: 'pt');
  /// ```
  static const portuguese =
      TTSLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português');

  /// French language - Standard French with comprehensive accentuation.
  ///
  /// Code: `fr`
  ///
  /// Handles all French accents: é, è, ê, à, ù, ç, etc.
  ///
  /// Example:
  /// ```dart
  /// await tts.synthesize('Bonjour, le monde!', language: 'fr');
  /// ```
  static const french =
      TTSLanguage(code: 'fr', name: 'French', nativeName: 'Français');

  /// List of all supported languages.
  ///
  /// Example:
  /// ```dart
  /// for (final lang in TTSLanguage.all) {
  ///   print('${lang.code}: ${lang.nativeName}');
  /// }
  /// // Output:
  /// // en: English
  /// // ko: 한국어
  /// // es: Español
  /// // pt: Português
  /// // fr: Français
  /// ```
  static const all = [
    english,
    korean,
    spanish,
    portuguese,
    french,
  ];

  /// Retrieves a language by its code.
  ///
  /// If the code is not found, returns [english] as the default.
  ///
  /// Example:
  /// ```dart
  /// final lang = TTSLanguage.fromCode('es');
  /// print(lang.nativeName); // 'Español'
  ///
  /// // Invalid code returns default (English)
  /// final invalid = TTSLanguage.fromCode('de');
  /// print(invalid.code); // 'en'
  /// ```
  ///
  /// Available codes: 'en', 'ko', 'es', 'pt', 'fr'
  static TTSLanguage fromCode(String code) {
    return all.firstWhere(
      (lang) => lang.code == code,
      orElse: () => english,
    );
  }

  @override
  String toString() => code;
}

/// Test strings for each language to verify TTS functionality.
///
/// Provides sample text in each supported language for testing
/// pronunciation and synthesis quality.
///
/// Example:
/// ```dart
/// // Get full test string
/// final text = TTSTestStrings.forLanguage('en');
/// await tts.synthesize(text, language: 'en');
///
/// // Get short test string
/// final short = TTSTestStrings.shortForLanguage('ko');
/// await tts.synthesize(short, language: 'ko');
/// ```
class TTSTestStrings {
  static const Map<String, String> _strings = {
    'en':
        'Hello, this is a test of the Supertonic text-to-speech system. The quick brown fox jumps over the lazy dog.',
    'ko': '안녕하세요, 이것은 슈퍼토닉 텍스트 음성 변환 시스템 테스트입니다. 빠른 갈색 여우가 게으른 개를 뛰어넘습니다.',
    'es':
        'Hola, esta es una prueba del sistema de síntesis de voz Supertonic. El rápido zorro marrón salta sobre el perro perezoso.',
    'pt':
        'Olá, este é um teste do sistema de síntese de voz Supertonic. A rápida raposa marrom salta sobre o cachorro preguiçoso.',
    'fr':
        'Bonjour, ceci est un test du système de synthèse vocale Supertonic. Le rapide renard brun saute par-dessus le chien paresseux.',
  };

  /// Gets a full test string for the specified language.
  ///
  /// Returns a comprehensive test sentence that includes various sounds
  /// and pronunciations specific to each language.
  ///
  /// If [langCode] is not found, returns the English test string.
  ///
  /// Example:
  /// ```dart
  /// final text = TTSTestStrings.forLanguage('en');
  /// // "Hello, this is a test of the Supertonic text-to-speech system..."
  /// ```
  ///
  /// Supported codes: 'en', 'ko', 'es', 'pt', 'fr'
  static String forLanguage(String langCode) {
    return _strings[langCode] ?? _strings['en']!;
  }

  static const Map<String, String> _shortStrings = {
    'en': 'Hello, this is a test.',
    'ko': '안녕하세요, 이것은 테스트입니다.',
    'es': 'Hola, esta es una prueba.',
    'pt': 'Olá, este é um teste.',
    'fr': 'Bonjour, ceci est un test.',
  };

  /// Gets a short test string for the specified language.
  ///
  /// Returns a brief, simple sentence ideal for quick tests or previews.
  ///
  /// If [langCode] is not found, returns the English short test string.
  ///
  /// Example:
  /// ```dart
  /// final text = TTSTestStrings.shortForLanguage('ko');
  /// // "안녕하세요, 이것은 테스트입니다."
  ///
  /// // Use in a quick test
  /// await tts.synthesize(
  ///   TTSTestStrings.shortForLanguage('es'),
  ///   language: 'es',
  /// );
  /// ```
  ///
  /// Supported codes: 'en', 'ko', 'es', 'pt', 'fr'
  static String shortForLanguage(String langCode) {
    return _shortStrings[langCode] ?? _shortStrings['en']!;
  }
}
