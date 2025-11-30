class Verse {
  final String id;
  final String verseText;
  final String reference;
  final String extraChildLine;
  final String imageAsset;

  const Verse({
    required this.id,
    required this.verseText,
    required this.reference,
    required this.extraChildLine,
    this.imageAsset = '',
  });
}