import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService with WidgetsBindingObserver {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;
  bool _isPlaying = false;

  bool get isMuted => _isMuted;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    WidgetsBinding.instance.addObserver(this);
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setSource(AssetSource('audio/background-music.m4a'));
    _isInitialized = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _player.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (_isPlaying && !_isMuted) {
        _player.resume();
      }
    }
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
