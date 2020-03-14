import 'main.dart';
import 'action.dart';
import 'reducer.dart';
import 'db_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

void middleware(Store<AppState> store, action, NextDispatcher next) async {
  print("$action を実行するよ!");
  if (action is AddTaskAction) {
    Database db = await DbProvider().db;
    final String sql = "INSERT INTO TodoList(task) VALUES ('${action.newTask}')";
    db.execute(sql);
    final String getLastRecordSql =
        "SELECT * FROM TodoList WHERE ROWID = last_insert_rowid()";
    final List<Map<String, dynamic>> newRecord =
        await db.rawQuery(getLastRecordSql);
    action.newRecord = newRecord;
  } else if (action is DeleteTaskAction) {
    Database db = await DbProvider().db;
    final String deleteSql = "DELETE FROM TodoList WHERE id=${action.deleteId}";
    final int _ = await db.rawDelete(deleteSql);
    final List<Map<String, dynamic>> result =
        await db.rawQuery("SELECT * FROM TodoList");
    action.result = result;
  } else if (action is EditTaskAction) {
    Database db = await DbProvider().db;
    final String updateSql =
        "UPDATE TodoList SET task='${action.editedTask}' WHERE id=${action.editedTaskId}";
    db.rawUpdate(updateSql);
    final List<Map<String, dynamic>> result =
        await db.rawQuery("SELECT * FROM TodoList");
    action.result = result;
  } else if (action is SyncTaskAction) {
    Database db = await DbProvider().db;
    final List<Map<String, dynamic>> result =
        await db.rawQuery("SELECT * FROM TodoList");
    action.result = result;
    print("無事DB処理が終わったよ！");
    print(action.result is List<Map<String, dynamic>>);
  }
  next(action);
}
