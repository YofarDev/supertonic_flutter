/// Voice style information for Supertonic TTS.
///
/// Provides metadata about different voice styles including description and
/// recommended use cases. Supertonic TTS offers 10 voice styles:
/// - 5 male voices (M1-M5): Codes starting with 'M'
/// - 5 female voices (F1-F5): Codes starting with 'F'
///
/// Example:
/// ```dart
/// final voice = TTSVoiceStyle.fromCode('M1');
/// print(voice.description);  // "Lively, upbeat male voice..."
/// print(voice.useCases);     // "Promotional videos, upbeat explainers..."
/// ```
///
/// See also:
/// - [all] for a map of all available voice styles
/// - [fromCode] to get a voice style by its code
class TTSVoiceStyle {
  /// The voice code (e.g., 'M1', 'F2').
  ///
  /// Use this code when calling [SupertonicTTS.synthesize]:
  /// ```dart
  /// await tts.synthesize('Hello', voiceStyle: 'M1');
  /// ```
  ///
  /// Gender is indicated by the first letter:
  /// - 'M' prefix: Male voice
  /// - 'F' prefix: Female voice
  final String code;

  /// Detailed description of the voice characteristics.
  ///
  /// Includes information about tone, energy, and personality.
  final String description;

  /// Recommended use cases for this voice style.
  ///
  /// Suggests the best scenarios to use this voice, such as
  /// "Promotional videos", "Corporate content", etc.
  final String useCases;

  /// Optional example text that showcases the voice well.
  final String? example;

  /// Creates a new voice style definition.
  ///
  /// This constructor is primarily used for defining the built-in
  /// voice styles. Use [fromCode] to retrieve an existing voice style.
  const TTSVoiceStyle({
    required this.code,
    required this.description,
    required this.useCases,
    this.example,
  });

  /// **M1** - Lively, upbeat male voice.
  ///
  /// Characteristics: Confident energy, standard clear tone
  ///
  /// Best for: Promotional videos, upbeat explainers, general-purpose narration, casual announcements
  static const m1 = TTSVoiceStyle(
    code: 'M1',
    description:
        'Lively, upbeat male voice with confident energy and a standard, clear tone.',
    useCases:
        'Promotional videos, upbeat explainers, general-purpose narration, casual announcements.',
  );

  /// **M2** - Deep, robust male voice.
  ///
  /// Characteristics: Calm, composed, serious, grounded presence
  ///
  /// Best for: Corporate content, serious announcements, documentaries, formal guidance
  static const m2 = TTSVoiceStyle(
    code: 'M2',
    description:
        'Deep, robust male voice; calm, composed, and serious with a grounded presence.',
    useCases:
        'Corporate content, serious announcements, documentaries, formal guidance.',
  );

  /// **M3** - Polished, authoritative male voice.
  ///
  /// Characteristics: Confident, trustworthy, strong presentation quality
  ///
  /// Best for: Business presentations, leadership messages, investor briefings, high-trust narration
  static const m3 = TTSVoiceStyle(
    code: 'M3',
    description:
        'Polished, authoritative male voice; confident and trustworthy with strong presentation quality.',
    useCases:
        'Business presentations, leadership messages, investor briefings, high-trust narration.',
  );

  /// **M4** - Soft, neutral-toned male voice.
  ///
  /// Characteristics: Gentle, approachable, youthful, friendly
  ///
  /// Best for: Educational content, friendly explainers, onboarding guides, youth-oriented narration
  static const m4 = TTSVoiceStyle(
    code: 'M4',
    description:
        'Soft, neutral-toned male voice; gentle and approachable with a youthful, friendly quality.',
    useCases:
        'Educational content, friendly explainers, onboarding guides, youth-oriented narration.',
  );

  /// **M5** - Warm, soft-spoken male voice.
  ///
  /// Characteristics: Calm, soothing, natural storytelling quality
  ///
  /// Best for: Audiobooks, relaxation content, bedtime stories, reflective or emotional narration
  static const m5 = TTSVoiceStyle(
    code: 'M5',
    description:
        'Warm, soft-spoken male voice; calm and soothing with a natural storytelling quality.',
    useCases:
        'Audiobooks, relaxation content, bedtime stories, reflective or emotional narration.',
  );

  /// **F1** - Calm female voice.
  ///
  /// Characteristics: Slightly low tone, steady, composed
  ///
  /// Best for: Customer service, guided instructions, meditative content, professional narration
  static const f1 = TTSVoiceStyle(
    code: 'F1',
    description:
        'Calm female voice with a slightly low tone; steady and composed.',
    useCases:
        'Customer service, guided instructions, meditative content, professional narration.',
  );

  /// **F2** - Bright, cheerful female voice.
  ///
  /// Characteristics: Lively, playful, youthful, spirited energy
  ///
  /// Best for: Youth content, playful ads, social media videos, character voices
  static const f2 = TTSVoiceStyle(
    code: 'F2',
    description:
        'Bright, cheerful female voice; lively, playful, and youthful with spirited energy.',
    useCases:
        'Youth content, playful ads, social media videos, character voices.',
  );

  /// **F3** - Professional announcer-style female voice.
  ///
  /// Characteristics: Clear, articulate, broadcast-ready
  ///
  /// Best for: Commercials, documentaries, news-style narration, formal presentations
  static const f3 = TTSVoiceStyle(
    code: 'F3',
    description:
        'Clear, professional announcer-style female voice; articulate and broadcast-ready.',
    useCases:
        'Commercials, documentaries, news-style narration, formal presentations.',
  );

  /// **F4** - Crisp, confident female voice.
  ///
  /// Characteristics: Distinct, expressive, strong delivery
  ///
  /// Best for: Business explainers, training videos, pitch decks, product announcements
  static const f4 = TTSVoiceStyle(
    code: 'F4',
    description:
        'Crisp, confident female voice; distinct and expressive with strong delivery.',
    useCases:
        'Business explainers, training videos, pitch decks, product announcements.',
  );

  /// **F5** - Kind, gentle female voice.
  ///
  /// Characteristics: Soft-spoken, calm, naturally soothing
  ///
  /// Best for: Audiobooks, supportive messages, wellness content, empathetic narration
  static const f5 = TTSVoiceStyle(
    code: 'F5',
    description:
        'Kind, gentle female voice; soft-spoken, calm, and naturally soothing.',
    useCases:
        'Audiobooks, supportive messages, wellness content, empathetic narration.',
  );

  /// Map of all available voice styles indexed by their code.
  ///
  /// Example:
  /// ```dart
  /// final allVoices = TTSVoiceStyle.all;
  /// print(allVoices.keys); // ['M1', 'M2', 'M3', 'M4', 'M5', 'F1', 'F2', 'F3', 'F4', 'F5']
  ///
  /// // Get specific voice
  /// final voice = TTSVoiceStyle.all['M1'];
  /// ```
  static const all = {
    'M1': m1,
    'M2': m2,
    'M3': m3,
    'M4': m4,
    'M5': m5,
    'F1': f1,
    'F2': f2,
    'F3': f3,
    'F4': f4,
    'F5': f5,
  };

  /// Retrieves a voice style by its code.
  ///
  /// If the code is not found, returns [m1] (the default male voice).
  ///
  /// Example:
  /// ```dart
  /// final voice = TTSVoiceStyle.fromCode('M1');
  /// print(voice.description);
  ///
  /// // Invalid code returns default (M1)
  /// final invalid = TTSVoiceStyle.fromCode('X1');
  /// print(invalid.code); // 'M1'
  /// ```
  ///
  /// Available codes: 'M1', 'M2', 'M3', 'M4', 'M5', 'F1', 'F2', 'F3', 'F4', 'F5'
  static TTSVoiceStyle fromCode(String code) {
    return all[code] ?? m1;
  }

  @override
  String toString() => code;
}
