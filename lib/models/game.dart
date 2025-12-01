class Game {
  final int? id;
  final String name;
  final int colorValue;
  final String iconPath;
  final String type; // 'video' or 'picture'

  Game({
    this.id,
    required this.name,
    required this.colorValue,
    required this.iconPath,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconPath': iconPath,
      'type': type,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'],
      name: map['name'],
      colorValue: map['colorValue'],
      iconPath: map['iconPath'],
      type: map['type'],
    );
  }
}
