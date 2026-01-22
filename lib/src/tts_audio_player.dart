import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'tts_result.dart';
import 'package:path_provider/path_provider.dart';

/// Audio player for TTS results
class TTSAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  bool _isDisposed = false;

  /// Play a TTS result
  Future<void> play(TTSResult result) async {
    if (_isDisposed) {
      throw StateError('TTSAudioPlayer has been disposed');
    }

    // Create a temporary file for the audio
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${tempDir.path}/supertonic_tts_$timestamp.wav';

    // Write WAV file
    final file = File(filePath);
    await file.writeAsBytes(result.toWavBytes());

    // Play the file
    final uri = Uri.file(filePath);
    await _player.setAudioSource(AudioSource.uri(uri));
    await _player.play();
  }

  /// Stop playback
  Future<void> stop() async {
    if (_isDisposed) return;
    await _player.stop();
  }

  /// Pause playback
  Future<void> pause() async {
    if (_isDisposed) return;
    await _player.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    if (_isDisposed) return;
    await _player.play();
  }

  /// Get the current player state
  PlayerState get playerState => _player.playerState;

  /// Stream of player state changes
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Whether audio is currently playing
  bool get isPlaying => _player.playing;

  /// Dispose the player and release resources
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _player.dispose();
  }
}
