import 'package:audioplayers/audioplayers.dart';
import 'tts_result.dart';

/// Audio player for playing TTS results.
///
/// This class wraps the `audioplayers` package to provide convenient playback
/// of [TTSResult] objects. It handles temporary file creation and cleanup
/// automatically.
///
/// Example:
/// ```dart
/// final tts = SupertonicTTS();
/// final player = TTSAudioPlayer();
///
/// // Initialize TTS
/// await tts.initialize();
///
/// // Synthesize and play
/// final result = await tts.synthesize('Hello, world!', language: 'en');
/// await player.play(result);
///
/// // Control playback
/// await player.pause();
/// await player.resume();
/// await player.stop();
///
/// // Monitor state
/// player.playerStateStream.listen((state) {
///   print('Playing: ${state == PlayerState.playing}');
/// });
///
/// // Clean up
/// player.dispose();
/// tts.dispose();
/// ```
///
/// See also:
/// - [TTSResult] for the audio data this class plays
/// - [SupertonicTTS.synthesize] for generating audio
class TTSAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  bool _isDisposed = false;

  /// Plays a TTS result.
  ///
  /// This method converts the [TTSResult] to a WAV file and plays it using
  /// the device's audio system. A temporary file is created automatically.
  ///
  /// Example:
  /// ```dart
  /// final result = await tts.synthesize('Hello', language: 'en');
  /// await player.play(result);
  /// ```
  ///
  /// Throws:
  /// - [StateError] if the player has been disposed
  ///
  /// Note: This will replace any currently playing audio.
  Future<void> play(TTSResult result) async {
    if (_isDisposed) {
      throw StateError('TTSAudioPlayer has been disposed');
    }

    // Keep playback in-memory so it works across native and web platforms.
    await _player.play(BytesSource(result.toWavBytes()));
  }

  /// Stops playback and resets the player to the beginning.
  ///
  /// Example:
  /// ```dart
  /// await player.stop();
  /// // Audio is stopped and can be restarted from the beginning
  /// ```
  ///
  /// Note: If the player is already stopped, this does nothing.
  Future<void> stop() async {
    if (_isDisposed) return;
    await _player.stop();
  }

  /// Pauses playback at the current position.
  ///
  /// Example:
  /// ```dart
  /// await player.pause();
  /// // Audio is paused, can be resumed with [resume]
  /// ```
  ///
  /// Note: Use [resume] to continue playback from the paused position.
  Future<void> pause() async {
    if (_isDisposed) return;
    await _player.pause();
  }

  /// Resumes playback from the paused position.
  ///
  /// Example:
  /// ```dart
  /// await player.pause();
  /// // ... later ...
  /// await player.resume();
  /// ```
  ///
  /// Note: If the player is not paused, this starts playback from the beginning.
  Future<void> resume() async {
    if (_isDisposed) return;
    await _player.resume();
  }

  /// Gets the current player state.
  ///
  /// Returns a [PlayerState] containing information about whether audio is
  /// playing, paused, stopped, etc.
  ///
  /// Example:
  /// ```dart
  /// final state = player.playerState;
  /// if (state == PlayerState.playing) {
  ///   print('Audio is playing');
  /// }
  /// ```
  ///
  /// For monitoring state changes, use [playerStateStream] instead.
  PlayerState get playerState => _player.state;

  /// Stream of player state changes.
  ///
  /// Emits a new [PlayerState] whenever the player state changes. This is
  /// useful for updating UI based on playback status.
  ///
  /// Example:
  /// ```dart
  /// player.playerStateStream.listen((state) {
  ///   if (state == PlayerState.playing) {
  ///     print('Now playing');
  ///   } else if (state == PlayerState.completed) {
  ///     print('Finished playing');
  ///   }
  /// });
  /// ```
  ///
  /// Note: Remember to cancel the subscription when done to avoid memory leaks.
  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;

  /// Whether audio is currently playing.
  ///
  /// Returns `true` if audio is actively playing, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (player.isPlaying) {
  ///   print('Audio is playing');
  /// }
  /// ```
  ///
  /// For more detailed state information, use [playerState].
  bool get isPlaying => _player.state == PlayerState.playing;

  /// Releases all resources and stops playback.
  ///
  /// Call this method when you're done using the player to free up resources.
  /// After calling [dispose], the player cannot be used again.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   player.dispose();
  ///   super.dispose();
  /// }
  /// ```
  ///
  /// Note: This method is safe to call multiple times.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _player.dispose();
  }
}
