import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_item.dart';
import '../models/game.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tammy_v2.db'); // New DB version
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE games ( 
  id $idType, 
  name $textType,
  colorValue $intType,
  iconPath $textType,
  type $textType
  )
''');

    await db.execute('''
CREATE TABLE game_items ( 
  id $idType, 
  text $textType,
  imagePath $textType,
  videoPath $textType,
  gameId $intType,
  FOREIGN KEY (gameId) REFERENCES games (id) ON DELETE CASCADE
  )
''');
  }

  // Game CRUD
  Future<Game> createGame(Game game) async {
    final db = await instance.database;
    final id = await db.insert('games', game.toMap());
    return Game(
      id: id,
      name: game.name,
      colorValue: game.colorValue,
      iconPath: game.iconPath,
      type: game.type,
    );
  }

  Future<List<Game>> readAllGames() async {
    final db = await instance.database;
    final result = await db.query('games');
    return result.map((json) => Game.fromMap(json)).toList();
  }

  Future<int> updateGame(Game game) async {
    final db = await instance.database;
    return db.update(
      'games',
      game.toMap(),
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  Future<int> deleteGame(int id) async {
    final db = await instance.database;
    return await db.delete(
      'games',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // GameItem CRUD
  Future<GameItem> createGameItem(GameItem item) async {
    final db = await instance.database;
    final id = await db.insert('game_items', item.toMap());
    return GameItem(
      id: id,
      text: item.text,
      imagePath: item.imagePath,
      videoPath: item.videoPath,
      gameId: item.gameId,
    );
  }

  Future<List<GameItem>> readGameItems(int gameId) async {
    final db = await instance.database;
    final orderBy = 'text ASC';
    
    final result = await db.query(
      'game_items', 
      where: 'gameId = ?', 
      whereArgs: [gameId], 
      orderBy: orderBy
    );

    return result.map((json) => GameItem.fromMap(json)).toList();
  }

  Future<int> deleteGameItem(int id) async {
    final db = await instance.database;
    return await db.delete(
      'game_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
