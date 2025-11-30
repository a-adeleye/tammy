import 'package:flutter/material.dart';
import '../data/verses_data.dart';
import '../services/speech_service.dart';

class VersesScreen extends StatefulWidget {
  const VersesScreen({super.key});

  @override
  State<VersesScreen> createState() => _VersesScreenState();
}

class _VersesScreenState extends State<VersesScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bible Verses", style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.yellow[200],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: versesData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _speakCurrent();
              },
              itemBuilder: (context, index) {
                final verse = versesData[index];
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    color: Colors.yellow[50],
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            verse.verseText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            verse.reference,
                            style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            verse.extraChildLine,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 24, color: Colors.black87),
                          ),
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
                  color: Colors.orange,
                ),
                FloatingActionButton.large(
                  onPressed: _speakCurrent,
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.volume_up, size: 48),
                ),
                IconButton(
                  onPressed: () {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
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

  void _speakCurrent() {
    final verse = versesData[_currentIndex];
    SpeechService.instance.speak("${verse.verseText} ${verse.extraChildLine}");
  }
}
