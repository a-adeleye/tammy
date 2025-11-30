import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../data/phrases_data.dart';
import '../services/speech_service.dart';
import '../services/audio_service.dart';

class ActionPhrasesScreen extends StatefulWidget {
  const ActionPhrasesScreen({super.key});

  @override
  State<ActionPhrasesScreen> createState() => _ActionPhrasesScreenState();
}

class _ActionPhrasesScreenState extends State<ActionPhrasesScreen> {
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
    if (_currentIndex < actionPhrases.length - 1) {
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
                  const Icon(Icons.star, size: 120, color: Colors.orange),
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
        title: const Text("I want...", style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.orange[200],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: actionPhrases.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final phrase = actionPhrases[index];
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: GestureDetector(
                    onTap: () {
                      SpeechService.instance.speak(phrase.text);
                      _showOverlay(context, phrase.text);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange[100]!, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image, size: 100, color: Colors.grey), // Placeholder
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                phrase.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
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
                  color: Colors.orange,
                ),
                FloatingActionButton.large(
                  onPressed: () => SpeechService.instance.repeat(),
                  backgroundColor: Colors.orange[300],
                  child: const Icon(Icons.replay, size: 32),
                ),
                IconButton(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward, size: 48),
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOverlay(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black12,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) Navigator.of(context).pop();
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }
}
