/// Configuration for text-to-speech synthesis.
///
/// Use this class to customize the quality, speed, and behavior of the TTS engine.
///
/// Example:
/// ```dart
/// final config = TTSConfig(
///   denoisingSteps: 5,
///   speechSpeed: 1.2,
///   silenceDuration: 0.5,
/// );
/// ```
///
/// See also:
/// - [denoisingSteps] for quality vs speed trade-offs
/// - [speechSpeed] for adjusting playback speed
/// - [silenceDuration] for controlling pauses between chunks
class TTSConfig {
  /// Number of denoising steps in the diffusion model (1-20).
  ///
  /// Controls the quality of the generated audio:
  /// - **1-3 steps**: Lower quality, faster processing (good for real-time)
  /// - **4-7 steps**: Good quality, medium speed (recommended for most use cases)
  /// - **8-12 steps**: High quality, slower processing (good for content creation)
  /// - **13-20 steps**: Excellent quality, very slow processing (for final renders)
  ///
  /// Default: `5`
  ///
  /// Example:
  /// ```dart
  /// // Quick preview
  /// TTSConfig(denoisingSteps: 3)
  ///
  /// // High-quality output
  /// TTSConfig(denoisingSteps: 10)
  /// ```
  final int denoisingSteps;

  /// Speech speed multiplier (0.5 - 2.0).
  ///
  /// Adjusts how fast or slow the speech is generated:
  /// - `0.5` - Half speed (slow, good for accessibility)
  /// - `0.75` - 75% speed (slower, easier to follow)
  /// - `1.0` - Normal speed
  /// - `1.25` - 125% speed (slightly faster)
  /// - `1.5` - 1.5x speed (fast, good for quick consumption)
  /// - `2.0` - Double speed (maximum speed)
  ///
  /// Default: `1.05` (slightly faster than normal)
  ///
  /// Example:
  /// ```dart
  /// // Slow speech for learning
  /// TTSConfig(speechSpeed: 0.75)
  ///
  /// // Fast speech for quick consumption
  /// TTSConfig(speechSpeed: 1.5)
  /// ```
  final double speechSpeed;

  /// Silence duration in seconds between text chunks (0.0 - 2.0).
  ///
  /// When synthesizing long text, it's split into chunks. This controls
  /// the pause duration between these chunks.
  ///
  /// - `0.0` - No pause between chunks
  /// - `0.3` - Short pause (default, natural flow)
  /// - `0.5` - Medium pause (good for distinct sentences)
  /// - `1.0+` - Long pause (good for paragraph breaks)
  ///
  /// Default: `0.3`
  ///
  /// Example:
  /// ```dart
  /// // No pauses, continuous flow
  /// TTSConfig(silenceDuration: 0.0)
  ///
  /// // Distinct pauses between sentences
  /// TTSConfig(silenceDuration: 0.5)
  /// ```
  final double silenceDuration;

  /// Creates a new TTS configuration.
  ///
  /// All parameters are optional and have sensible defaults.
  ///
  /// Example:
  /// ```dart
  /// // Use defaults
  /// final config = TTSConfig();
  ///
  /// // Custom configuration
  /// final config = TTSConfig(
  ///   denoisingSteps: 8,
  ///   speechSpeed: 1.2,
  ///   silenceDuration: 0.5,
  /// );
  /// ```
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
