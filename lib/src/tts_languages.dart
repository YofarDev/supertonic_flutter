/// Supported languages for text-to-speech synthesis.
///
/// Supertonic 3 supports **31 languages** with native pronunciation.
///
/// Example:
/// ```dart
/// // Get language info
/// final lang = TTSLanguage.fromCode('de');
/// print(lang.name);       // 'German'
/// print(lang.nativeName); // 'Deutsch'
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

  /// English language. Code: `en`
  static const english =
      TTSLanguage(code: 'en', name: 'English', nativeName: 'English');

  /// Korean language with Hangul Jamo decomposition. Code: `ko`
  static const korean =
      TTSLanguage(code: 'ko', name: 'Korean', nativeName: '한국어');

  /// Japanese language. Code: `ja`
  static const japanese =
      TTSLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語');

  /// Spanish language with accent handling. Code: `es`
  static const spanish =
      TTSLanguage(code: 'es', name: 'Spanish', nativeName: 'Español');

  /// Portuguese language (Brazilian). Code: `pt`
  static const portuguese =
      TTSLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português');

  /// French language. Code: `fr`
  static const french =
      TTSLanguage(code: 'fr', name: 'French', nativeName: 'Français');

  /// German language. Code: `de`
  static const german =
      TTSLanguage(code: 'de', name: 'German', nativeName: 'Deutsch');

  /// Italian language. Code: `it`
  static const italian =
      TTSLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano');

  /// Dutch language. Code: `nl`
  static const dutch =
      TTSLanguage(code: 'nl', name: 'Dutch', nativeName: 'Nederlands');

  /// Russian language. Code: `ru`
  static const russian =
      TTSLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский');

  /// Ukrainian language. Code: `uk`
  static const ukrainian =
      TTSLanguage(code: 'uk', name: 'Ukrainian', nativeName: 'Українська');

  /// Polish language. Code: `pl`
  static const polish =
      TTSLanguage(code: 'pl', name: 'Polish', nativeName: 'Polski');

  /// Czech language. Code: `cs`
  static const czech =
      TTSLanguage(code: 'cs', name: 'Czech', nativeName: 'Čeština');

  /// Slovak language. Code: `sk`
  static const slovak =
      TTSLanguage(code: 'sk', name: 'Slovak', nativeName: 'Slovenčina');

  /// Croatian language. Code: `hr`
  static const croatian =
      TTSLanguage(code: 'hr', name: 'Croatian', nativeName: 'Hrvatski');

  /// Slovenian language. Code: `sl`
  static const slovenian =
      TTSLanguage(code: 'sl', name: 'Slovenian', nativeName: 'Slovenščina');

  /// Bulgarian language. Code: `bg`
  static const bulgarian =
      TTSLanguage(code: 'bg', name: 'Bulgarian', nativeName: 'Български');

  /// Romanian language. Code: `ro`
  static const romanian =
      TTSLanguage(code: 'ro', name: 'Romanian', nativeName: 'Română');

  /// Hungarian language. Code: `hu`
  static const hungarian =
      TTSLanguage(code: 'hu', name: 'Hungarian', nativeName: 'Magyar');

  /// Greek language. Code: `el`
  static const greek =
      TTSLanguage(code: 'el', name: 'Greek', nativeName: 'Ελληνικά');

  /// Swedish language. Code: `sv`
  static const swedish =
      TTSLanguage(code: 'sv', name: 'Swedish', nativeName: 'Svenska');

  /// Danish language. Code: `da`
  static const danish =
      TTSLanguage(code: 'da', name: 'Danish', nativeName: 'Dansk');

  /// Finnish language. Code: `fi`
  static const finnish =
      TTSLanguage(code: 'fi', name: 'Finnish', nativeName: 'Suomi');

  /// Estonian language. Code: `et`
  static const estonian =
      TTSLanguage(code: 'et', name: 'Estonian', nativeName: 'Eesti');

  /// Latvian language. Code: `lv`
  static const latvian =
      TTSLanguage(code: 'lv', name: 'Latvian', nativeName: 'Latviešu');

  /// Lithuanian language. Code: `lt`
  static const lithuanian =
      TTSLanguage(code: 'lt', name: 'Lithuanian', nativeName: 'Lietuvių');

  /// Turkish language. Code: `tr`
  static const turkish =
      TTSLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe');

  /// Arabic language. Code: `ar`
  static const arabic =
      TTSLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية');

  /// Hindi language. Code: `hi`
  static const hindi =
      TTSLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी');

  /// Indonesian language. Code: `id`
  static const indonesian =
      TTSLanguage(code: 'id', name: 'Indonesian', nativeName: 'Indonesia');

  /// Vietnamese language. Code: `vi`
  static const vietnamese =
      TTSLanguage(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt');

  /// List of all 31 supported languages.
  ///
  /// Example:
  /// ```dart
  /// for (final lang in TTSLanguage.all) {
  ///   print('${lang.code}: ${lang.nativeName}');
  /// }
  /// ```
  static const all = [
    english,
    korean,
    japanese,
    spanish,
    portuguese,
    french,
    german,
    italian,
    dutch,
    russian,
    ukrainian,
    polish,
    czech,
    slovak,
    croatian,
    slovenian,
    bulgarian,
    romanian,
    hungarian,
    greek,
    swedish,
    danish,
    finnish,
    estonian,
    latvian,
    lithuanian,
    turkish,
    arabic,
    hindi,
    indonesian,
    vietnamese,
  ];

  /// Retrieves a language by its code.
  ///
  /// If the code is not found, returns [english] as the default.
  ///
  /// Example:
  /// ```dart
  /// final lang = TTSLanguage.fromCode('de');
  /// print(lang.nativeName); // 'Deutsch'
  /// ```
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
  static String forLanguage(String langCode) {
    return _strings[langCode] ?? _strings['en']!;
  }

  static const Map<String, String> _shortStrings = {
    'en': 'Hello, this is a test.',
    'ko': '안녕하세요, 이것은 테스트입니다.',
    'ja': 'こんにちは、これはテストです。',
    'es': 'Hola, esta es una prueba.',
    'pt': 'Olá, este é um teste.',
    'fr': 'Bonjour, ceci est un test.',
    'de': 'Hallo, dies ist ein Test.',
    'it': 'Ciao, questo è un test.',
    'nl': 'Hallo, dit is een test.',
    'ru': 'Здравствуйте, это тест.',
    'uk': 'Привіт, це тест.',
    'pl': 'Cześć, to jest test.',
    'cs': 'Ahoj, toto je test.',
    'sk': 'Ahoj, toto je test.',
    'hr': 'Bok, ovo je test.',
    'sl': 'Živjo, to je test.',
    'bg': 'Здравейте, това е тест.',
    'ro': 'Salut, acesta este un test.',
    'hu': 'Szia, ez egy teszt.',
    'el': 'Γεια σας, αυτό είναι ένα τεστ.',
    'sv': 'Hej, detta är ett test.',
    'da': 'Hej, dette er en test.',
    'fi': 'Hei, tämä on testi.',
    'et': 'Tere, see on test.',
    'lv': 'Sveiki, tas ir tests.',
    'lt': 'Sveiki, tai yra testas.',
    'tr': 'Merhaba, bu bir testtir.',
    'ar': 'مرحبًا، هذا اختبار.',
    'hi': 'नमस्ते, यह एक परीक्षण है।',
    'id': 'Halo, ini adalah sebuah tes.',
    'vi': 'Xin chào, đây là một bài kiểm tra.',
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
  /// ```
  static String shortForLanguage(String langCode) {
    return _shortStrings[langCode] ?? _shortStrings['en']!;
  }
}
