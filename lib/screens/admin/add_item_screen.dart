import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../models/game.dart';
import '../../models/game_item.dart';
import '../../services/database_helper.dart';

class AddItemScreen extends StatefulWidget {
  final Game game;

  const AddItemScreen({super.key, required this.game});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _textController = TextEditingController();
  File? _imageFile;
  File? _videoFile;
  final _picker = ImagePicker();
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveItem() async {
    bool isVideoRequired = widget.game.type == 'video';

    if (_textController.text.isEmpty ||
        _imageFile == null ||
        (isVideoRequired && _videoFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill text, image${isVideoRequired ? ' and video' : ''}',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileNameTimestamp =
          DateTime.now().millisecondsSinceEpoch.toString();

      final imageFileName =
          'img_$fileNameTimestamp${path.extension(_imageFile!.path)}';
      final savedImage = await _imageFile!.copy(
        path.join(appDir.path, imageFileName),
      );

      String videoPath = '';
      if (_videoFile != null) {
        final videoFileName =
            'vid_$fileNameTimestamp${path.extension(_videoFile!.path)}';
        final savedVideo = await _videoFile!.copy(
          path.join(appDir.path, videoFileName),
        );
        videoPath = savedVideo.path;
      }

      final newItem = GameItem(
        text: _textController.text,
        imagePath: savedImage.path,
        videoPath: videoPath,
        gameId: widget.game.id!,
      );

      await DatabaseHelper.instance.createGameItem(newItem);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving item: $e')));
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
      appBar: AppBar(title: const Text('Add New Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image, size: 22),
              label: const Text(
                'Select Flashcard Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7AB8B0),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 22,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
            if (_imageFile != null) ...[
              const SizedBox(height: 10),
              Image.file(_imageFile!, height: 150, fit: BoxFit.cover),
            ],
            const SizedBox(height: 20),
            if (widget.game.type == 'video') ...[
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.videocam, size: 22),
                label: const Text(
                  'Select Video',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9CA67C),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
              if (_videoFile != null) ...[
                const SizedBox(height: 10),
                const Text(
                  'Video selected',
                  style: TextStyle(color: Colors.green),
                ),
              ],
              const SizedBox(height: 40),
            ],
            ElevatedButton(
              onPressed: _isSaving ? null : _saveItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child:
                  _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Item', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
