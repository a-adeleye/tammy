import 'story_scene.dart';

class Story {
  final String id;
  final String title;
  final String coverImageAsset;
  final List<StoryScene> scenes;
  final String? finalQuestion;
  final List<String>? answerOptions;
  final int? correctAnswerIndex;

  const Story({
    required this.id,
    required this.title,
    this.coverImageAsset = '',
    required this.scenes,
    this.finalQuestion,
    this.answerOptions,
    this.correctAnswerIndex,
  });
}