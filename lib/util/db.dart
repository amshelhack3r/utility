import 'package:mutall_water/models/Meter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:async';

const TABLE_NAME = 'meter';

class DatabaseProvider {
  Database database;
  var path;

  Future init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    path = join(directory.path, 'meters.db');

    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      print("created database");
      var sql = """CREATE TABLE $TABLE_NAME(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            pk INTEGER NOT NULL,
            type TEXT NOT NULL, 
            num TEXT NOT NULL UNIQUE, 
            name TEXT NOT NULL)""";
      
      var reading = """CREATE TABLE READING(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          meter INTEGER NOT NULL,
          type TEXT NOT NULL
          date TEXT NOT NULL
          value DOUBLE NOT NULL
      
      """;
      await db.execute(sql);
    }, onDowngrade: (Database db, int version, int i) async {
// Delete the database
      await deleteDatabase(path);
    });

    print("database created and initialized");

  }
  Future dropDb() async{
    await init();
    await database.delete(TABLE_NAME);
  }

  Future<Meter> insertMeter(Meter meter) async {
    await init();
    try {
      await database.insert(TABLE_NAME, meter.toMap());
    }on DatabaseException catch(e){
      print(e);
    }
      return meter;
  }

  Future<List<Meter>> queryMeters() async {
    await init();
    List<Meter> meters = [];
    List<Map> maps = await database.query(TABLE_NAME, columns: ['pk', 'name', 'num', 'type'], where: "name !=?", whereArgs: ["NOT ASSIGNED"]);
    if (maps.length > 0) {
      for (var meter in maps) {
        meters.add(Meter.fromMap(meter));
      }
      return meters;
    }
    return null;
  }
}
