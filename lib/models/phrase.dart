enum PhraseCategory { action, object, affirmation, verse }

class Phrase {
  final String id;
  final String text;
  final PhraseCategory category;
  final String imageAsset;
  final String? extraText;

  const Phrase({
    required this.id,
    required this.text,
    required this.category,
    this.imageAsset = '',
    this.extraText,
  });
}