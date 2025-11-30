enum ObjectCategory { toys, food, clothes, bathroom, other }

class ObjectItem {
  final String id;
  final String label;
  final String? extraLine;
  final String imageAsset;
  final ObjectCategory category;

  const ObjectItem({
    required this.id,
    required this.label,
    this.extraLine,
    this.imageAsset = '',
    required this.category,
  });
}