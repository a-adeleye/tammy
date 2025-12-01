import 'dart:io';
import 'package:flutter/material.dart';
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
    _refreshGames();
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
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  leading: game.iconPath.isNotEmpty
                      ? Image.file(File(game.iconPath), width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.gamepad),
                  title: Text(game.name),
                  subtitle: Text(game.type == 'video' ? 'Video Game' : 'Picture Game'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddEditGameScreen(game: game)),
                          );
                          _refreshGames();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteGame(game.id!),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ConfigureGameScreen(game: game)),
                          );
                        },
                      ),
                    ],
                  ),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
