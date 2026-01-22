/// Configuration for text-to-speech synthesis
class TTSConfig {
  /// Number of denoising steps (1-20). Higher values = better quality but slower.
  final int denoisingSteps;

  /// Speech speed multiplier (0.5 - 2.0). 1.0 is normal speed.
  final double speechSpeed;

  /// Silence duration in seconds between text chunks.
  final double silenceDuration;

  const TTSConfig({
    this.denoisingSteps = 5,
    this.speechSpeed = 1.05,
    this.silenceDuration = 0.3,
  });

  TTSConfig copyWith({
    int? denoisingSteps,
    double? speechSpeed,
    double? silenceDuration,
  }) {
    return TTSConfig(
      denoisingSteps: denoisingSteps ?? this.denoisingSteps,
      speechSpeed: speechSpeed ?? this.speechSpeed,
      silenceDuration: silenceDuration ?? this.silenceDuration,
    );
  }

  @override
  String toString() {
    return 'TTSConfig(denoisingSteps: $denoisingSteps, speechSpeed: $speechSpeed, silenceDuration: $silenceDuration)';
  }
}
