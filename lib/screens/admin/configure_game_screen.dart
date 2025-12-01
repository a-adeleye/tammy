import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../../models/game_item.dart';
import '../../services/database_helper.dart';
import 'add_item_screen.dart';

class ConfigureGameScreen extends StatefulWidget {
  final Game game;

  const ConfigureGameScreen({
    super.key,
    required this.game,
  });

  @override
  State<ConfigureGameScreen> createState() => _ConfigureGameScreenState();
}

class _ConfigureGameScreenState extends State<ConfigureGameScreen> {
  late Future<List<GameItem>> _gameItemsFuture;

  @override
  void initState() {
    super.initState();
    _refreshGameItems();
  }

  void _refreshGameItems() {
    setState(() {
      _gameItemsFuture = DatabaseHelper.instance.readGameItems(widget.game.id!);
    });
  }

  void _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteGameItem(id);
    _refreshGameItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configure "${widget.game.name}"')),
      body: FutureBuilder<List<GameItem>>(
        future: _gameItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items found. Add one!'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: item.imagePath.isNotEmpty
                      ? Image.file(File(item.imagePath), width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                  title: Text(item.text),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(item.id!),
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
            MaterialPageRoute(
              builder: (context) => AddItemScreen(game: widget.game),
            ),
          );
          _refreshGameItems();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
