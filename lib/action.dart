//Action
class AddTaskAction {
  final String newTask;
  AddTaskAction({this.newTask});
}

class DeleteTaskAction {
  final int deleteIndex;
  DeleteTaskAction({this.deleteIndex});
}

class EditTaskAction {
  final String editedTask;
  final int editedTaskIndex;
  EditTaskAction({this.editedTask, this.editedTaskIndex});
}
