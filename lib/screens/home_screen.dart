import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game.dart';
import '../services/audio_service.dart';
import '../services/database_helper.dart';
import 'admin/admin_login_screen.dart';
import 'generic_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Game>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initAudio();
    _refreshGames();
  }

  void _refreshGames() {
    setState(() {
      _gamesFuture = DatabaseHelper.instance.readAllGames();
    });
  }

  void _initAudio() async {
    await AudioService.instance.init();
    AudioService.instance.playMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Let's Talk!",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF4E8D6),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await _navigateTo(context, const AdminLoginScreen());
              _refreshGames(); // Refresh on return from admin
            },
          ),
          IconButton(
            icon: Icon(
              AudioService.instance.isMuted
                  ? Icons.volume_off
                  : Icons.volume_up,
            ),
            onPressed: () {
              setState(() {
                AudioService.instance.toggleMute();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: FutureBuilder<List<Game>>(
          future: _gamesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No games configured. Ask an admin to add games!'),
              );
            }

            final games = snapshot.data!;
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: games.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final game = games[index];
                return _buildGameCard(context, game);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Game game) {
    return GestureDetector(
      onTap: () {
        _navigateTo(context, GenericGameScreen(game: game));
      },

      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color:
              game.iconPath.isNotEmpty
                  ? Colors.transparent
                  : Color(game.colorValue),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child:
              game.iconPath.isNotEmpty
                  ? Image.file(
                    File(game.iconPath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                  : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        game.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Future<void> _navigateTo(BuildContext context, Widget destination) async {
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
