import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;
  bool _isPlaying = false;

  bool get isMuted => _isMuted;

  Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setSource(AssetSource('audio/background-music.m4a'));
  }

  Future<void> playMusic() async {
    if (_isMuted) return;
    if (!_isPlaying) {
      await _player.resume();
      _isPlaying = true;
    }
  }

  Future<void> stopMusic() async {
    if (_isPlaying) {
      await _player.pause();
      _isPlaying = false;
    }
  }

  Future<void> playCelebration() async {
    if (_isMuted) return;
    // Pause background music if playing
    if (_isPlaying) {
      await _player.pause();
    }
    // Play celebration song
    final celebrationPlayer = AudioPlayer();
    await celebrationPlayer.play(AssetSource('audio/celebration-song.m4a'));
    
    // Resume background music after celebration (approx 5 seconds or when finished)
    celebrationPlayer.onPlayerComplete.listen((event) async {
      celebrationPlayer.dispose();
      if (_isPlaying && !_isMuted) {
        await _player.resume();
      }
    });
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _player.setVolume(0);
    } else {
      _player.setVolume(1.0);
      if (!_isPlaying) {
        playMusic();
      }
    }
  }
}
