import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/game.dart';
import '../../services/database_helper.dart';
import 'add_edit_game_screen.dart';
import 'configure_game_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<Game>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _refreshGames();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _refreshGames() {
    setState(() {
      _gamesFuture = DatabaseHelper.instance.readAllGames();
    });
  }

  void _deleteGame(int id) async {
    await DatabaseHelper.instance.deleteGame(id);
    _refreshGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: FutureBuilder<List<Game>>(
        future: _gamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No games found. Add one!'));
          }

          final games = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: const Color(0xFFFDF8F0),
                // subtle variant of your theme
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        game.iconPath.isNotEmpty
                            ? Image.file(
                              File(game.iconPath),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              color: const Color(0xFFF4E8D6),
                              child: const Icon(Icons.gamepad, size: 28),
                            ),
                  ),
                  title: Text(
                    game.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    game.type == 'video' ? 'Video Game' : 'Picture Game',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined),
                        color: Colors.blueGrey,
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AddEditGameScreen(game: game),
                            ),
                          );
                          _refreshGames();
                        },
                      ),
                      IconButton(
                        tooltip: 'Configure',
                        icon: const Icon(Icons.settings_outlined),
                        color: Colors.green.shade700,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ConfigureGameScreen(game: game),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red.shade600,
                        onPressed: () => _deleteGame(game.id!),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfigureGameScreen(game: game),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditGameScreen()),
          );
          _refreshGames();
        },
        backgroundColor: const Color(0xFFF4E8D6),
        foregroundColor: Colors.black87,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
