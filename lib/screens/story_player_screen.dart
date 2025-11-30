import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/story.dart';
import '../services/speech_service.dart';
import '../services/audio_service.dart';

class StoryPlayerScreen extends StatefulWidget {
  final Story story;

  const StoryPlayerScreen({super.key, required this.story});

  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends State<StoryPlayerScreen> {
  int _currentIndex = 0;
  bool _showFinalQuestion = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _speakCurrentScene();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _speakCurrentScene() async {
    if (_showFinalQuestion) {
      if (widget.story.finalQuestion != null) {
        await SpeechService.instance.speak(widget.story.finalQuestion!);
      }
      return;
    }
    final scene = widget.story.scenes[_currentIndex];
    await SpeechService.instance.speak(scene.text);
  }

  void _next() {
    if (_currentIndex < widget.story.scenes.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _speakCurrentScene();
    } else {
      setState(() {
        _showFinalQuestion = true;
      });
      _speakCurrentScene();
    }
  }

  void _previous() {
    if (_showFinalQuestion) {
      setState(() {
        _showFinalQuestion = false;
      });
      _speakCurrentScene();
    } else if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _speakCurrentScene();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        backgroundColor: Colors.blue[200],
      ),
      body: Stack(
        children: [
          _showFinalQuestion ? _buildFinalQuestion() : _buildScene(),
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

  Widget _buildScene() {
    final scene = widget.story.scenes[_currentIndex];
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 100, color: Colors.grey), // Placeholder
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  scene.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _previous,
                      icon: const Icon(Icons.arrow_back, size: 48),
                      color: Colors.blue,
                    ),
                    FloatingActionButton.large(
                      onPressed: () => SpeechService.instance.speak(scene.practiceLine ?? scene.text),
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.volume_up, size: 48),
                    ),
                    IconButton(
                      onPressed: _next,
                      icon: const Icon(Icons.arrow_forward, size: 48),
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalQuestion() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Well Done!",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 20),
        if (widget.story.finalQuestion != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.story.finalQuestion!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        const SizedBox(height: 20),
        if (widget.story.answerOptions != null)
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: widget.story.answerOptions!.asMap().entries.map((entry) {
              final index = entry.key;
              final text = entry.value;
              return ElevatedButton(
                onPressed: () {
                  if (index == widget.story.correctAnswerIndex) {
                    _confettiController.play();
                    AudioService.instance.playCelebration();
                    SpeechService.instance.speak("Correct! Good job!");
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Good Job!"),
                        content: const Icon(Icons.star, size: 100, color: Colors.yellow),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Go back to list
                            },
                            child: const Text("Finish"),
                          )
                        ],
                      ),
                    );
                  } else {
                    SpeechService.instance.speak("Try again.");
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: Text(text),
              );
            }).toList(),
          ),
      ],
    );
  }
}
