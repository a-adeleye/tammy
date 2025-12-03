import 'dart:io';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:video_player/video_player.dart';
import '../models/game.dart';
import '../models/game_item.dart';
import '../services/database_helper.dart';
import '../services/speech_service.dart';
import '../services/audio_service.dart';

class GenericGameScreen extends StatefulWidget {
  final Game game;

  const GenericGameScreen({
    super.key,
    required this.game,
  });

  @override
  State<GenericGameScreen> createState() => _GenericGameScreenState();
}

class _GenericGameScreenState extends State<GenericGameScreen> {
  final PageController _pageController = PageController();
  late ConfettiController _confettiController;
  int _currentIndex = 0;
  bool _isFinished = false;
  List<GameItem> _items = [];
  bool _isLoading = true;

  // Video State
  VideoPlayerController? _videoController;
  bool _isPlayingVideo = false;
  bool _isVideoFinished = false;
  int? _playingIndex;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await DatabaseHelper.instance.readGameItems(widget.game.id!);
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _next() {
    if (_isPlayingVideo) return;
    if (_currentIndex < _items.length - 1) {
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

  void _previous() {
    if (_isPlayingVideo) return;
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _playVideo(String videoPath, int index) async {
    if (_videoController != null) {
      await _videoController!.dispose();
    }

    _videoController = VideoPlayerController.file(File(videoPath));
    await _videoController!.initialize();
    
    setState(() {
      _isPlayingVideo = true;
      _playingIndex = index;
      _isVideoFinished = false;
    });

    await _videoController!.play();
    
    _videoController!.addListener(() {
      if (_videoController!.value.position >= _videoController!.value.duration && !_isVideoFinished) {
        setState(() {
          _isVideoFinished = true;
        });
      }
    });
  }

  void _replayVideo() {
    setState(() {
      _isVideoFinished = false;
    });
    _videoController!.seekTo(Duration.zero);
    _videoController!.play();
  }

  void _backToCard() {
    setState(() {
      _isPlayingVideo = false;
      _playingIndex = null;
      _isVideoFinished = false;
    });
    _videoController?.pause();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color(widget.game.colorValue).withValues(alpha: 0.2); // Lighter version for background
    final primaryColor = Color(widget.game.colorValue);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.game.name), backgroundColor: backgroundColor),
        body: const Center(child: Text("No items added yet. Ask an admin to configure the game!")),
      );
    }

    if (_isFinished) {
      return Scaffold(
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 120, color: primaryColor),
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

    return PopScope(
      canPop: !_isPlayingVideo,
      child: Scaffold(
        appBar: _isPlayingVideo
            ? null
            : AppBar(
                title: Text(widget.game.name, style: const TextStyle(fontSize: 24)),
                backgroundColor: backgroundColor,
                automaticallyImplyLeading: true,
              ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: _isPlayingVideo ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                    itemCount: _items.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: GestureDetector(
                          onTap: () {
                            if (!_isPlayingVideo) {
                              if (widget.game.type == 'video') {
                                if (item.videoPath.isNotEmpty) {
                                  _playVideo(item.videoPath, index);
                                }
                              } else {
                                SpeechService.instance.speak(item.text);
                              }
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: _previous,
                                icon: const Icon(Icons.arrow_back, size: 48),
                                color: _isPlayingVideo ? Colors.grey : primaryColor,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: item.imagePath.isNotEmpty
                                        ? Image.file(File(item.imagePath), fit: BoxFit.contain)
                                        : const Icon(Icons.image, size: 100, color: Colors.grey),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: _next,
                                icon: const Icon(Icons.arrow_forward, size: 48),
                                color: _isPlayingVideo ? Colors.grey : primaryColor,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (_isPlayingVideo && _videoController != null && _videoController!.value.isInitialized)
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      ),
                      if (_isVideoFinished)
                        Container(
                          color: Colors.black45,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay, size: 64, color: Colors.white),
                                onPressed: _replayVideo,
                              ),
                              const SizedBox(width: 40),
                              IconButton(
                                icon: const Icon(Icons.close, size: 64, color: Colors.white),
                                onPressed: _backToCard,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
