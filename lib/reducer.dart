import 'package:learn_sqlite/db_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'main.dart';
import 'action.dart';

//Reducer
AppState reducer(AppState prev, action) {
  print("I am SyncTaskAction");
  print(action);
  if (action is AddTaskAction) {
    return AppState(addTaskReducer(prev, action.newTask, action.newRecord));
  } else if (action is DeleteTaskAction) {
    return AppState(deleteTaskReducer(prev, action.deleteId, action.result));
  } else if (action is EditTaskAction) {
    return AppState(editTaskReducer(
        prev, action.editedTask, action.editedTaskId, action.result));
  } else if (action is SyncTaskAction) {
    return AppState(syncTaskReducer(prev, action.result));
  }
}

List<Map<String, dynamic>> addTaskReducer(
    AppState prev, String newTask, List<Map<String, dynamic>> newRecord) {
  return []
    ..addAll(prev.todoTasks)
    ..add(newRecord[0]);
}

List<Map<String, dynamic>> deleteTaskReducer(
    AppState prev, int deleteId, List<Map<String, dynamic>> result) {
  return []..addAll(result);
}

List<Map<String, dynamic>> editTaskReducer(AppState prev, String editedTask,
    int editedTaskId, List<Map<String, dynamic>> result) {
  return result;
}

List<Map<String, dynamic>> syncTaskReducer(
    AppState prev, List<Map<String, dynamic>> result) {
  return result;
}
