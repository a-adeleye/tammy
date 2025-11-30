import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  SpeechService._internal();
  static final SpeechService instance = SpeechService._internal();

  final FlutterTts _tts = FlutterTts();
  String _lastText = '';

  Future<void> speak(String text) async {
    _lastText = text;
    await _tts.stop();
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.speak(text);
  }

  Future<void> repeat() async {
    if (_lastText.isEmpty) return;
    await speak(_lastText);
  }
}