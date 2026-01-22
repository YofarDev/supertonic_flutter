/// Supported languages for text-to-speech
class TTSLanguage {
  final String code;
  final String name;
  final String nativeName;

  const TTSLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  static const english =
      TTSLanguage(code: 'en', name: 'English', nativeName: 'English');
  static const korean =
      TTSLanguage(code: 'ko', name: 'Korean', nativeName: '한국어');
  static const spanish =
      TTSLanguage(code: 'es', name: 'Spanish', nativeName: 'Español');
  static const portuguese =
      TTSLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português');
  static const french =
      TTSLanguage(code: 'fr', name: 'French', nativeName: 'Français');

  static const all = [
    english,
    korean,
    spanish,
    portuguese,
    french,
  ];

  static TTSLanguage fromCode(String code) {
    return all.firstWhere(
      (lang) => lang.code == code,
      orElse: () => english,
    );
  }

  @override
  String toString() => code;
}

/// Test strings for each language to verify TTS functionality
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

  static String shortForLanguage(String langCode) {
    return _shortStrings[langCode] ?? _shortStrings['en']!;
  }
}
