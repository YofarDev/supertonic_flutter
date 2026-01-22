/// Voice style information for Supertonic TTS
class TTSVoiceStyle {
  final String code;
  final String gender;
  final String description;
  final String useCases;
  final String? example;

  const TTSVoiceStyle({
    required this.code,
    required this.gender,
    required this.description,
    required this.useCases,
    this.example,
  });

  static const m1 = TTSVoiceStyle(
    code: 'M1',
    gender: 'Male',
    description: 'Lively, upbeat male voice with confident energy and a standard, clear tone.',
    useCases: 'Promotional videos, upbeat explainers, general-purpose narration, casual announcements.',
  );

  static const m2 = TTSVoiceStyle(
    code: 'M2',
    gender: 'Male',
    description: 'Deep, robust male voice; calm, composed, and serious with a grounded presence.',
    useCases: 'Corporate content, serious announcements, documentaries, formal guidance.',
  );

  static const m3 = TTSVoiceStyle(
    code: 'M3',
    gender: 'Male',
    description: 'Polished, authoritative male voice; confident and trustworthy with strong presentation quality.',
    useCases: 'Business presentations, leadership messages, investor briefings, high-trust narration.',
  );

  static const m4 = TTSVoiceStyle(
    code: 'M4',
    gender: 'Male',
    description: 'Soft, neutral-toned male voice; gentle and approachable with a youthful, friendly quality.',
    useCases: 'Educational content, friendly explainers, onboarding guides, youth-oriented narration.',
  );

  static const m5 = TTSVoiceStyle(
    code: 'M5',
    gender: 'Male',
    description: 'Warm, soft-spoken male voice; calm and soothing with a natural storytelling quality.',
    useCases: 'Audiobooks, relaxation content, bedtime stories, reflective or emotional narration.',
  );

  static const f1 = TTSVoiceStyle(
    code: 'F1',
    gender: 'Female',
    description: 'Calm female voice with a slightly low tone; steady and composed.',
    useCases: 'Customer service, guided instructions, meditative content, professional narration.',
  );

  static const f2 = TTSVoiceStyle(
    code: 'F2',
    gender: 'Female',
    description: 'Bright, cheerful female voice; lively, playful, and youthful with spirited energy.',
    useCases: 'Youth content, playful ads, social media videos, character voices.',
  );

  static const f3 = TTSVoiceStyle(
    code: 'F3',
    gender: 'Female',
    description: 'Clear, professional announcer-style female voice; articulate and broadcast-ready.',
    useCases: 'Commercials, documentaries, news-style narration, formal presentations.',
  );

  static const f4 = TTSVoiceStyle(
    code: 'F4',
    gender: 'Female',
    description: 'Crisp, confident female voice; distinct and expressive with strong delivery.',
    useCases: 'Business explainers, training videos, pitch decks, product announcements.',
  );

  static const f5 = TTSVoiceStyle(
    code: 'F5',
    gender: 'Female',
    description: 'Kind, gentle female voice; soft-spoken, calm, and naturally soothing.',
    useCases: 'Audiobooks, supportive messages, wellness content, empathetic narration.',
  );

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

  static TTSVoiceStyle fromCode(String code) {
    return all[code] ?? m1;
  }

  @override
  String toString() => code;
}
