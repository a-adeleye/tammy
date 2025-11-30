import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../data/affirmations_data.dart';
import '../services/speech_service.dart';
import '../services/audio_service.dart';

class AffirmationsScreen extends StatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen> {
  final PageController _pageController = PageController();
  late ConfettiController _confettiController;
  int _currentIndex = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < affirmationPhrases.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
                  const Icon(Icons.star, size: 120, color: Colors.pink),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("I am...", style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.pink[200],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: affirmationPhrases.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _speakCurrent();
              },
              itemBuilder: (context, index) {
                final affirmation = affirmationPhrases[index];
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    color: Colors.pink[50],
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            affirmation.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.pink),
                          ),
                          if (affirmation.extraText != null) ...[
                            const SizedBox(height: 20),
                            Text(
                              affirmation.extraText!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24, color: Colors.black54),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  icon: const Icon(Icons.arrow_back, size: 48),
                  color: Colors.pink,
                ),
                FloatingActionButton.large(
                  onPressed: _speakCurrent,
                  backgroundColor: Colors.pink,
                  child: const Icon(Icons.volume_up, size: 48),
                ),
                IconButton(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward, size: 48),
                  color: Colors.pink,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _speakCurrent() {
    final affirmation = affirmationPhrases[_currentIndex];
    SpeechService.instance.speak("${affirmation.text} ${affirmation.extraText ?? ''}");
  }
}
