import 'package:learn_sqlite/db_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'main.dart';
import 'action.dart';

//Reducer
Future<AppState> reducer(AppState prev, action) async {
  print(action);
  if (action is AddTaskAction) {
    return AppState(await addTaskReducer(prev, action.newTask));
  } else if (action is DeleteTaskAction) {
    return AppState(await deleteTaskReducer(prev, action.deleteIndex));
  } else if (action is EditTaskAction) {
    return AppState(
        await editTaskReducer(prev, action.editedTask, action.editedTaskIndex));
  }
}

Future<List<Map<String, dynamic>>> addTaskReducer(
    AppState prev, String newTask) async {
  Database db = await DbProvider().db;
  final String sql = "INSERT INTO TodoList (task) VALUES ($newTask)";
  db.execute(sql);
  final String getLastRecordSql =
      "SELECT * FROM TodoList WHERE ROWID = last_insert_rowid()";
  final List<Map<String, dynamic>> newRecord =
      await db.rawQuery(getLastRecordSql);

  return []
    ..addAll(prev.todoTasks)
    ..add(newRecord[0]);
}

Future<List<Map<String, dynamic>>> deleteTaskReducer(
    AppState prev, int deleteId) async {
  Database db = await DbProvider().db;
  final String deleteSql = "DELETE FROM TodoList WHERE id=$deleteId";
  final int _ = await db.rawDelete(deleteSql);

  final List<Map<String, dynamic>> result =
      await db.rawQuery("SELECT * FROM TodoList");
  return []..addAll(result);
}

Future<List<Map<String, dynamic>>> editTaskReducer(
    AppState prev, String editedTask, int editedTaskId) async {
  Database db = await DbProvider().db;
  final String updateSql =
      "UPDATE TodoList SET fuga='$editedTask' WHERE id=$editedTaskId";
  db.rawUpdate(updateSql);
  final List<Map<String, dynamic>> result =
      await db.rawQuery("SELECT * FROM TodoList");
  return result;
}

Future<List<Map<String, dynamic>>> syncTaskReducer(AppState prev) async {
  Database db = await DbProvider().db;
  final List<Map<String, dynamic>> result =
      await db.rawQuery("SELECT * FROM TodoList");
  return result;
}
