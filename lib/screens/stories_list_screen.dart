import 'package:flutter/material.dart';
import '../data/stories_data.dart';
import 'story_player_screen.dart';
import '../services/audio_service.dart';

class StoriesListScreen extends StatefulWidget {
  const StoriesListScreen({super.key});

  @override
  State<StoriesListScreen> createState() => _StoriesListScreenState();
}

class _StoriesListScreenState extends State<StoriesListScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stories", style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.blue[200],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: storiesData.length,
              itemBuilder: (context, index) {
                final story = storiesData[index];
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    child: InkWell(
                      onTap: () {
                        _navigateToStory(context, story);
                      },
                      borderRadius: BorderRadius.circular(32),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.book, size: 60, color: Colors.blue),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                story.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Tap to Read",
                                style: TextStyle(fontSize: 20, color: Colors.grey),
                              ),
                            ],
                          ),
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
                  color: Colors.blue,
                ),
                const SizedBox(width: 48), // Spacer
                IconButton(
                  onPressed: () {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  icon: const Icon(Icons.arrow_forward, size: 48),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToStory(BuildContext context, dynamic story) async {
    await AudioService.instance.stopMusic();
    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryPlayerScreen(story: story),
        ),
      );
      AudioService.instance.playMusic();
    }
  }
}
