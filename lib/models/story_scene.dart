class StoryScene {
  final String id;
  final String text;
  final String? practiceLine;
  final String imageAsset;

  const StoryScene({
    required this.id,
    required this.text,
    this.practiceLine,
    this.imageAsset = '',
  });
}