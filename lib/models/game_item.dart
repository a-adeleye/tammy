class GameItem {
  final int? id;
  final String text;
  final String imagePath;
  final String videoPath;
  final int gameId;

  GameItem({
    this.id,
    required this.text,
    required this.imagePath,
    required this.videoPath,
    required this.gameId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imagePath': imagePath,
      'videoPath': videoPath,
      'gameId': gameId,
    };
  }

  factory GameItem.fromMap(Map<String, dynamic> map) {
    return GameItem(
      id: map['id'],
      text: map['text'],
      imagePath: map['imagePath'],
      videoPath: map['videoPath'],
      gameId: map['gameId'],
    );
  }
}
