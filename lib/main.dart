// redux.dart | MIT License | https://github.com/johnpryan/redux.dart/blob/master/LICENSE
// flutter_redux | MIT License | https://github.com/brianegan/flutter_redux/blob/master/LICENSE
// sqflite | MIT License | https://github.com/tekartik/sqflite/blob/master/sqflite/LICENSE
// path | BSD License | https://github.com/dart-lang/path/blob/master/LICENSE
// path_provider | BSD License | https://github.com/flutter/plugins/blob/master/packages/path_provider/path_provider/LICENSE


import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:meta/meta.dart';
import 'action.dart';
import 'package:sqflite/sqflite.dart';
import 'db_provider.dart';
import 'middleware.dart';
import 'reducer.dart';

@immutable
class AppState {
  //{id: "dbのid", tasks: "タスクの内容"}
  final List<Map<String, dynamic>> todoTasks;
  AppState(this.todoTasks);
}

enum PopupMenuAction {
  DONE,
  EDIT,
  DELETE,
}

//View
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Store<AppState> store = Store(reducer, initialState: AppState([]), middleware: [middleware]);
  DbProvider _dbProvider = DbProvider();
  Database db = await _dbProvider.db;

  List<Map<String, dynamic>> list = await db.rawQuery("select * from TodoList");
  print(list);

  runApp(MyApp(store));
}

class MyApp extends StatelessWidget {
  MyApp(this.store);
  final Store store;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Redux todo list',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(title: 'Redux Todo List', store: store),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.store}) : super(key: key);

  final String title;
  final Store<AppState> store;
  @override
  _MyHomePageState createState() => _MyHomePageState(store);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState(this.store);
  Store<AppState> store;
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
          return StoreProvider<AppState>(
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
                                hintText: store.state.todoTasks[editTaskIndex]["task"]),
                            onSubmitted: (task) {
                              store.dispatch(EditTaskAction(
                                  editedTask: task,
                                  editedTaskId:
                                      store.state.todoTasks[editTaskIndex]["id"]));
                              _textFieldController.clear();
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
                                  editedTaskId:
                                      store.state.todoTasks[editTaskIndex]["id"]));
                              _textFieldController.clear();
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
                              store.dispatch(DeleteTaskAction(
                                  deleteId:
                                      store.state.todoTasks[doneTaskIndex]["id"]));
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      )));
        });
  }

  DbProvider _dbProvider;
  Database db;

  @override
  void initState() {
    // TODO: implement initState
    // TODO: DBの初期化
    print("initState");
    _dbProvider = DbProvider();
    try {
      store.dispatch(SyncTaskAction());
    } catch (e) {
      print(e);
    }


    super.initState();
  }

  void getDB() async {
    db = await _dbProvider.db;
  }

  hoge() async {}

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
                    return _menu.map((s) {
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
                        store.dispatch(
                            DeleteTaskAction(deleteId: todoTasks[index]["id"]));
                        break;
                    }
                  }),
                  title: Text(todoTasks[index]["task"]),
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
