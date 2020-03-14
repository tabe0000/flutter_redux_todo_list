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

List<String> addTaskReducer(AppState prev, String newTask) {
  return []
    ..addAll(prev.todoTasks)
    ..add(newTask);
}

List<String> deleteTaskReducer(AppState prev, int deleteIndex) {
  return []
    ..addAll(prev.todoTasks)
    ..removeAt(deleteIndex);
}

List<String> editTaskReducer(
    AppState prev, String editedTask, int editedTaskIndex) {
  List<String> newList = [];
  newList.addAll(prev.todoTasks);
  print(newList);
  newList[editedTaskIndex] = editedTask;
  return newList;
}
