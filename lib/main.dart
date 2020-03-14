import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:meta/meta.dart';
import 'package:flutter/rendering.dart';

@immutable
class AppState {
  final List<String> todoTasks;
  AppState(this.todoTasks);
}

enum PopupMenuAction {
  DONE,
  EDIT,
  DELETE,
}

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

//Reducer
AppState reducer(AppState prev, action) {
  print(action);
  if (action is AddTaskAction) {
    return AppState(addTaskReducer(prev, action.newTask));
  } else if (action is DeleteTaskAction) {
    print("im deleteAction");
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

//View
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Redux todo list',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(title: 'Redux Todo List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Store<AppState> store =
      Store(reducer, initialState: AppState(["take coffee"]));
  TextEditingController _textFieldController = TextEditingController();
  var _menu = [
    PopupMenuAction.DONE,
    PopupMenuAction.EDIT,
    PopupMenuAction.DELETE
  ];

  _displayAddDialog(BuildContext context, Store<AppState> store) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StoreProvider(
              store: store,
              child: StoreConnector(
                  converter: (Store<AppState> store) => store,
                  builder: (context, store) => AlertDialog(
                        title: Text('New Task'),
                        content: TextField(
                            controller: _textFieldController,
                            decoration:
                                InputDecoration(hintText: "add task ..."),
                            onSubmitted: (task) {
                              store.dispatch(AddTaskAction(newTask: task));
                              Navigator.of(context).pop();
                            }),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text('CANCEL'),
                            onPressed: () {
                              _textFieldController.clear();
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text("SUBMIT"),
                            onPressed: () {
                              store.dispatch(AddTaskAction(
                                  newTask: _textFieldController.text));
                              _textFieldController.clear();
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      )));
        });
  }

  _displayEditDialog(
      BuildContext context, Store<AppState> store, int editTaskIndex) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StoreProvider(
              store: store,
              child: StoreConnector(
                  converter: (Store<AppState> store) => store,
                  builder: (context, store) => AlertDialog(
                        title: Text('Edit Task'),
                        content: TextField(
                            controller: _textFieldController,
                            decoration: InputDecoration(
                                hintText: store.state.todoTasks[editTaskIndex]),
                            onSubmitted: (task) {
                              store.dispatch(EditTaskAction(
                                  editedTask: task,
                                  editedTaskIndex: editTaskIndex));
                              Navigator.of(context).pop();
                            }),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text('CANCEL'),
                            onPressed: () {
                              _textFieldController.clear();
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text("UPDATE"),
                            onPressed: () {
                              store.dispatch(EditTaskAction(
                                  editedTask: _textFieldController.text,
                                  editedTaskIndex: editTaskIndex));
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      )));
        });
  }

  _displayDoneDialog(
      BuildContext context, Store<AppState> store, int doneTaskIndex) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StoreProvider(
              store: store,
              child: StoreConnector(
                  converter: (Store<AppState> store) => store,
                  builder: (context, store) => AlertDialog(
                        title: Text('Congraturation!!!'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("OK"),
                            onPressed: () {
                              store.dispatch(
                                  DeleteTaskAction(deleteIndex: doneTaskIndex));
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      )));
        });
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: StoreConnector(
          converter: (Store<AppState> store) => store.state.todoTasks,
          builder: (context, todoTasks) => ListView.builder(
              itemCount: todoTasks.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: const Icon(Icons.comment),
                  trailing:
                      PopupMenuButton(itemBuilder: (BuildContext context) {
                    return _menu.indexedMap((i, s) {
                      return PopupMenuItem(
                        child: Text(s.toString().toUpperCase().split('.').last),
                        value: s,
                      );
                    }).toList();
                  }, onSelected: (v) {
                    print(v);
                    switch (v) {
                      case PopupMenuAction.DONE:
                        _displayDoneDialog(context, store, index);
                        break;
                      case PopupMenuAction.EDIT:
                        _displayEditDialog(context, store, index);
                        break;
                      case PopupMenuAction.DELETE:
                        store.dispatch(DeleteTaskAction(deleteIndex: index));
                        break;
                    }
                  }),
                  title: Text(todoTasks[index]),
                );
              }),
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _displayAddDialog(context, store),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

extension IndexedMap<T, E> on List<T> {
  List<E> indexedMap<E>(E Function(int index, T item) function) {
    List<E> list = [];
    this.asMap().forEach((index, element) {
      list.add(function(index, element));
    });
    return list;
  }
}
