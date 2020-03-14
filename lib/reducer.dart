import 'package:learn_sqlite/db_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'main.dart';
import 'action.dart';

//Reducer
AppState reducer(AppState prev, action) {
  print(action);
  if (action is AddTaskAction) {
    return AppState(addTaskReducer(prev, action.newTask));
  } else if (action is DeleteTaskAction) {
    return AppState(deleteTaskReducer(prev, action.deleteIndex));
  } else if (action is EditTaskAction) {
    return AppState(
        editTaskReducer(prev, action.editedTask, action.editedTaskIndex));
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

List<Map<String, dynamic>> editTaskReducer(
    AppState prev, String editedTask, int editedTaskIndex) {
  List<String> newList = [];
  newList.addAll(prev.todoTasks);
  print(newList);
  newList[editedTaskIndex] = editedTask;
  return newList;
}
