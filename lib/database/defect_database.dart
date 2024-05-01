import 'package:coworker/model/defect.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DefectDatabase {
  static final DefectDatabase _instance = DefectDatabase._();
  factory DefectDatabase() => _instance;

  DefectDatabase._() {
    _initDB();
  }

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath,'defect11.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE defects (id INTEGER PRIMARY KEY AUTOINCREMENT, uid TEXT, site INTEGER, building TEXT, house TEXT, reg_name TEXT, reg_phone TEXT, space TEXT, area TEXT, work TEXT, sort TEXT, claim TEXT, pic1 TEXT, pic2 TEXT, sent TEXT, synced INTEGER, completed INTEGER, deleted INTEGER)');
  }

  Future<int> addDefect(Defect defect) async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.insert('defects', defect.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<int> deleteDefect(int id) async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.delete('defects', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> updateDefect(Defect defect) async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.update('defects', defect.toMap(), where: 'id = ?', whereArgs: [defect.id]);
    });
  }

  Future<Defect> getDefectById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> defect = await db.query('defects', where: 'id = ?', whereArgs: [id]);
    return Defect.fromMap(defect[0]);
  }


  Future<int> getSentDefects(String uid, int site, String building, String house) async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query('defects', where:"uid=? and site=? and building=? and house=? and synced=1 and deleted=0", whereArgs: [uid, site, building, house]);

    return data.length;
  }

  Future<List<Defect>> getAllDefects(String uid, int site, String building, String house) async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query('defects', where:"uid=? and site=? and building=? and house=? and deleted=0", whereArgs: [uid, site, building, house], orderBy: 'id DESC');
    
    return List.generate(data.length, (index) => Defect.fromMap(data[index]));
  }

  Future<List<Defect>> getAllDelDefects(String uid, int site, String building, String house) async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query('defects', where:"uid=? and site=? and building=? and house=? and deleted=1", whereArgs: [uid, site, building, house], orderBy: 'id DESC');

    return List.generate(data.length, (index) => Defect.fromMap(data[index]));
  }
}