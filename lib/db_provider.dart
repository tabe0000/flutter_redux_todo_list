import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DbProvider {
  static Database _db;
  Future<Database> get db async {
    if (_db != null) return _db;

    await init();
    return _db;
  }

  void init() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, "todolist.db");
    print(path);
    _db = await openDatabase(path, version: 1,
        onCreate: (Database newDb, int version) {
      print("onCreate now!");
      newDb.execute("CREATE TABLE TodoList(id INTEGER PRIMARY KEY AUTOINCREMENT, task TEXT)");
    });
  }
}
