//Action
class AddTaskAction {
  final String newTask;
  List<Map<String, dynamic>> newRecord;
  AddTaskAction({this.newTask});
}

class DeleteTaskAction {
  final int deleteId;
  List<Map<String, dynamic>> result;
  DeleteTaskAction({this.deleteId});
}

class EditTaskAction {
  final String editedTask;
  final int editedTaskId;
  List<Map<String, dynamic>> result;
  EditTaskAction({this.editedTask, this.editedTaskId});
}

class SyncTaskAction {
  List<Map<String, dynamic>> result;
  SyncTaskAction();
}
