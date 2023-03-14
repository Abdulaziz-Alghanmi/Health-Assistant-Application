import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await intialDb();
      return _db;
    } else {
      return _db;
    }
  }

  intialDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'HA.db');
    Database mydb = await openDatabase(path,
        onCreate: _onCreate, version: 3, onUpgrade: _onUpgrade);
    return mydb;
  }

  _onUpgrade(Database db, int oldversion, int newversion) {
    print("onUpgrade =====================================");
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE 'profile' (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
    "name" TEXT,
    "age" INTEGER,
    "height" REAL,
    "weight" REAL,
    "diseases" TEXT
  )
 ''');

    await db.execute('''
  CREATE TABLE 'vitalSigns' (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
    "recored" REAL,
    "SystolicRecored" REAL,
    "DiastolicRecored" REAL,
    "date" TEXT,
    "type" TEXT
  )
 ''');
    print(" onCreate =====================================");
  }

  readData(String sql) async {
    Database mydb = await db;
    List<Map> response = await mydb.rawQuery(sql);
    return response;
  }

  insertData(String sql) async {
    Database mydb = await db;
    int response = await mydb.rawInsert(sql);
    return response;
  }

  updateData(String sql) async {
    Database mydb = await db;
    int response = await mydb.rawUpdate(sql);
    return response;
  }

  deleteData(String sql) async {
    Database mydb = await db;
    int response = await mydb.rawDelete(sql);
    return response;
  }

  deleteMyDatabase() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'HA.db');
    await deleteDatabase(path);
  }
}
