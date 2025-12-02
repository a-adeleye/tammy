import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../models/game.dart';
import '../../services/database_helper.dart';

class AddEditGameScreen extends StatefulWidget {
  final Game? game;

  const AddEditGameScreen({super.key, this.game});

  @override
  State<AddEditGameScreen> createState() => _AddEditGameScreenState();
}

class _AddEditGameScreenState extends State<AddEditGameScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late Color _selectedColor;
  late String _selectedType;
  File? _iconFile;
  final _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.game?.name ?? '');
    _selectedColor =
        widget.game != null ? Color(widget.game!.colorValue) : Colors.blue;
    _selectedType = widget.game?.type ?? 'video';
    if (widget.game != null && widget.game!.iconPath.isNotEmpty) {
      _iconFile = File(widget.game!.iconPath);
    }
  }

  Future<void> _pickIcon() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _iconFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) return;
    if (_iconFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an icon')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String iconPath = _iconFile!.path;
      final appDir = await getApplicationDocumentsDirectory();
      if (!path.isWithin(appDir.path, iconPath)) {
        final fileName =
            'icon_${DateTime.now().millisecondsSinceEpoch}${path.extension(iconPath)}';
        final savedImage = await _iconFile!.copy(
          path.join(appDir.path, fileName),
        );
        iconPath = savedImage.path;
      }

      final game = Game(
        id: widget.game?.id,
        name: _nameController.text,
        colorValue: _selectedColor.value,
        iconPath: iconPath,
        type: _selectedType,
      );

      if (widget.game == null) {
        await DatabaseHelper.instance.createGame(game);
      } else {
        await DatabaseHelper.instance.updateGame(game);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving game: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game == null ? 'Add Game' : 'Edit Game'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Game Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a name'
                            : null,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Game Color'),
                trailing: CircleAvatar(backgroundColor: _selectedColor),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Pick a color'),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              pickerColor: _selectedColor,
                              onColorChanged: (color) {
                                setState(() {
                                  _selectedColor = color;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                  );
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Game Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'video',
                    child: Text('Video (Flashcard + Video)'),
                  ),
                  DropdownMenuItem(
                    value: 'picture',
                    child: Text('Picture (Flashcard + TTS)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _pickIcon,
                icon: const Icon(Icons.image, size: 20),
                label: const Text(
                  'Select Icon',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4E8D6),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
              if (_iconFile != null) ...[
                const SizedBox(height: 10),
                Image.file(_iconFile!, height: 300, fit: BoxFit.contain),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child:
                    _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Save Game',
                          style: TextStyle(fontSize: 18),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
