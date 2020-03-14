//Action
class AddTaskAction {
  final String newTask;
  AddTaskAction({this.newTask});
}

class DeleteTaskAction {
  final int deleteId;
  DeleteTaskAction({this.deleteId});
}

class EditTaskAction {
  final String editedTask;
  final int editedTaskId;
  EditTaskAction({this.editedTask, this.editedTaskId});
}

class SyncTaskAction {
  //property nothing
}

