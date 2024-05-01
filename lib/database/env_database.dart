import 'package:coworker/model/env.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class EnvDatabase {
  static final EnvDatabase _instance = EnvDatabase._();
  factory EnvDatabase() => _instance;

  EnvDatabase._() {
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
    final path = join(dbPath, 'data01.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE site (id INTEGER PRIMARY KEY, site_code INTEGER, site_name TEXT, status INTEGER)');
    await db.execute('CREATE TABLE house (id INTEGER PRIMARY KEY, site_code INTEGER, site_name TEXT, building_no TEXT, house_no TEXT, type TEXT, line_no INTEGER)');
    await db.execute('CREATE TABLE space (id INTEGER PRIMARY KEY, site_code INTEGER, space_name TEXT)');
    await db.execute('CREATE TABLE area (id INTEGER PRIMARY KEY, site_code INTEGER, area_name TEXT)');
    await db.execute('CREATE TABLE work (id INTEGER PRIMARY KEY, site_code INTEGER, work_name TEXT)');
    await db.execute('CREATE TABLE sort (id INTEGER PRIMARY KEY, site_code INTEGER, sort_name TEXT)');
  }

  // ============================================= Site ==========================================================
  Future<int> addSite(Site site) async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.insert('site', site.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<int> deleteAllSite() async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.delete('site');
    });
  }

  Future<List<Site>> getAllSite() async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query('site', orderBy: 'site_name ASC');

    return List.generate(data.length, (index) => Site.fromMap(data[index]));
  }

  // ============================================= House ==========================================================
  Future<int> addHouse(House house) async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.insert('house', house.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<int> deleteAllHouse() async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.delete('house');
    });
  }

  Future<List<House>> getAllHouse() async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query('house', orderBy: 'building_no, house_no ASC');

    return List.generate(data.length, (index) => House.fromMap(data[index]));
  }

// ============================================= Space ==========================================================
  Future<int> addSpace(Space space) async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.insert('space', space.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<int> deleteAllSpace() async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.delete('space');
    });
  }

  Future<List<Space>> getAllSpace(int site_code) async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query('space', where:"site_code=?", whereArgs: [site_code], orderBy: 'space_name ASC');

    return List.generate(data.length, (index) => Space.fromMap(data[index]));
  }

// ============================================= Area ==========================================================
  Future<int> addArea(Area area) async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.insert('area', area.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<int> deleteAllArea() async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.delete('area');
    });
  }

  Future<List<Area>> getAllArea(int site_code) async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query('area', where:"site_code=?", whereArgs: [site_code], orderBy: 'area_name ASC');

    return List.generate(data.length, (index) => Area.fromMap(data[index]));
  }

// ============================================= Work ==========================================================
  Future<int> addWork(Work work) async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.insert('work', work.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<int> deleteAllWork() async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.delete('work');
    });
  }

  Future<List<Work>> getAllWork(int site_code) async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query('work', where:"site_code=?", whereArgs: [site_code], orderBy: 'work_name ASC');

    return List.generate(data.length, (index) => Work.fromMap(data[index]));
  }

// ============================================= Sort ==========================================================
  Future<int> addSort(Sort sort) async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.insert('sort', sort.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<int> deleteAllSort() async {
    final db = await database;
    return db.transaction((txn) async {
      return await txn.delete('sort');
    });
  }

  Future<List<Sort>> getAllSort(int site_code) async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query('sort', where:"site_code=?", whereArgs: [site_code], orderBy: 'sort_name ASC');

    return List.generate(data.length, (index) => Sort.fromMap(data[index]));
  }
}
