import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../data/phrases_data.dart';
import '../data/objects_data.dart';
import '../data/affirmations_data.dart';
import '../data/verses_data.dart';
import '../services/speech_service.dart';
import '../services/audio_service.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final List<dynamic> _sessionItems = [];
  int _currentIndex = 0;
  bool _isFinished = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _generateSession();
    _speakCurrent();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _generateSession() {
    final random = Random();
    // Pick 2 action phrases
    for (var i = 0; i < 2; i++) {
      _sessionItems.add(actionPhrases[random.nextInt(actionPhrases.length)]);
    }
    // Pick 2 objects
    for (var i = 0; i < 2; i++) {
      _sessionItems.add(objectItems[random.nextInt(objectItems.length)]);
    }
    // Pick 1 affirmation
    _sessionItems.add(affirmationPhrases[random.nextInt(affirmationPhrases.length)]);
    // Pick 1 verse
    _sessionItems.add(versesData[random.nextInt(versesData.length)]);

    _sessionItems.shuffle();
  }

  void _speakCurrent() async {
    if (_isFinished) return;
    final item = _sessionItems[_currentIndex];
    String textToSpeak = '';
    // item is already dynamic, so we can just proceed
    if (true) {
      // This is a bit hacky, better to have a common interface, but for now:
      if (item.runtimeType.toString() == 'Phrase') {
        textToSpeak = item.text;
      } else if (item.runtimeType.toString() == 'ObjectItem') {
        textToSpeak = item.label;
      } else if (item.runtimeType.toString() == 'Verse') {
        textToSpeak = item.verseText;
      }
    }
    await SpeechService.instance.speak(textToSpeak);
  }

  void _next() {
    if (_currentIndex < _sessionItems.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _speakCurrent();
    } else {
      setState(() {
        _isFinished = true;
      });
      _confettiController.play();
      AudioService.instance.playCelebration();
      SpeechService.instance.speak("All done! Great job!");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return Scaffold(
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, size: 120, color: Colors.yellow),
                  const SizedBox(height: 20),
                  const Text("Great Job!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back to Home"),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              ),
            ),
          ],
        ),
      );
    }

    final item = _sessionItems[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's Play!"),
        backgroundColor: Colors.green[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Center(
                  child: _buildItemContent(item),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FloatingActionButton.large(
              onPressed: _next,
              backgroundColor: Colors.green,
              child: const Icon(Icons.check, size: 48),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemContent(dynamic item) {
    String text = '';
    String subText = '';
    IconData icon = Icons.star;
    Color color = Colors.black;

    if (item.runtimeType.toString() == 'Phrase') {
      text = item.text;
      subText = item.extraText ?? '';
      icon = Icons.chat_bubble;
      color = Colors.orange;
    } else if (item.runtimeType.toString() == 'ObjectItem') {
      text = item.label;
      subText = item.extraLine ?? '';
      icon = Icons.category;
      color = Colors.purple;
    } else if (item.runtimeType.toString() == 'Verse') {
      text = item.verseText;
      subText = item.extraChildLine;
      icon = Icons.book;
      color = Colors.yellow[800]!;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: color),
        const SizedBox(height: 24),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        if (subText.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            subText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}
