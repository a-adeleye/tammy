import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/object_item.dart';
import '../data/objects_data.dart';
import '../services/speech_service.dart';
import '../services/audio_service.dart';

class ObjectsScreen extends StatefulWidget {
  const ObjectsScreen({super.key});

  @override
  State<ObjectsScreen> createState() => _ObjectsScreenState();
}

class _ObjectsScreenState extends State<ObjectsScreen> {
  ObjectCategory _selectedCategory = ObjectCategory.toys;
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
    final filteredItems = objectItems.where((item) => item.category == _selectedCategory).toList();
    if (_currentIndex < filteredItems.length - 1) {
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
                  const Icon(Icons.star, size: 120, color: Colors.purple),
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

    final filteredItems = objectItems.where((item) => item.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Things at home", style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.purple[200],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: ObjectCategory.values.map((category) {
                if (category == ObjectCategory.other || category == ObjectCategory.bathroom) return const SizedBox.shrink(); // Skip empty for now
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ChoiceChip(
                    label: Text(
                      category.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                          _isFinished = false; // Reset finished state
                          _currentIndex = 0;
                          _pageController.jumpToPage(0); // Reset to first page of new category
                        });
                      }
                    },
                    selectedColor: Colors.purple[300],
                    backgroundColor: Colors.grey[200],
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: filteredItems.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: GestureDetector(
                    onTap: () {
                      _speakItem(item);
                      _showOverlay(context, item.label);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.purple[100]!, width: 2),
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
                            const Icon(Icons.category, size: 100, color: Colors.grey), // Placeholder
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                item.label,
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
                  color: Colors.purple,
                ),
                const SizedBox(width: 48), // Spacer for center
                IconButton(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward, size: 48),
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _speakItem(ObjectItem item) async {
    await SpeechService.instance.speak(item.label);
    if (item.extraLine != null) {
      await Future.delayed(const Duration(seconds: 2));
      await SpeechService.instance.speak(item.extraLine!);
    }
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
