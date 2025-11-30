import 'package:flutter/material.dart';
import 'action_phrases_screen.dart';
import 'objects_screen.dart';
import 'stories_list_screen.dart';
import 'affirmations_screen.dart';
import 'verses_screen.dart';
import 'session_screen.dart';
import '../services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  void _initAudio() async {
    await AudioService.instance.init();
    AudioService.instance.playMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's Talk!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[100],
        actions: [
          IconButton(
            icon: Icon(AudioService.instance.isMuted ? Icons.volume_off : Icons.volume_up),
            onPressed: () {
              setState(() {
                AudioService.instance.toggleMute();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _navigateTo(context, const SessionScreen());
              },
              icon: const Icon(Icons.play_arrow, size: 32),
              label: const Text("Play All", style: TextStyle(fontSize: 24)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildModeCard(context, "I want...", Colors.orange[200]!, const ActionPhrasesScreen()),
                  const SizedBox(width: 16),
                  _buildModeCard(context, "Things at home", Colors.purple[200]!, const ObjectsScreen()),
                  const SizedBox(width: 16),
                  _buildModeCard(context, "Stories", Colors.blue[200]!, const StoriesListScreen()),
                  const SizedBox(width: 16),
                  _buildModeCard(context, "I am...", Colors.pink[200]!, const AffirmationsScreen()),
                  const SizedBox(width: 16),
                  _buildModeCard(context, "Bible Verses", Colors.yellow[200]!, const VersesScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, String title, Color color, Widget destination) {
    return GestureDetector(
      onTap: () {
        _navigateTo(context, destination);
      },
      child: Container(
        width: 250, // Fixed width for horizontal cards
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget destination) async {
    await AudioService.instance.stopMusic();
    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
      AudioService.instance.playMusic();
    }
  }
}
