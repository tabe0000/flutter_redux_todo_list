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

class AddTaskAction {
  final String newTask;
  AddTaskAction({this.newTask});
}

class DeleteTaskAction {
  final int deleteIndex;
  DeleteTaskAction({this.deleteIndex});
}

AppState reducer(AppState prev, action) {
  if (action is AddTaskAction) {
    print("im add action reducer.");
    print(action.newTask);
    return AppState(addTaskReducer(prev, action.newTask));
  }else if(action is DeleteTaskAction) {
    return AppState(deleteTaskReducer(prev, action.deleteIndex));
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  var _menu = ["delete"];

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
                  trailing: PopupMenuButton(
                      itemBuilder: (BuildContext context) {
                        return _menu.indexedMap((i, s) {
                          return PopupMenuItem(
                            child: Text(s),
                            value: s,
                          );
                        }).toList();
                      },
                      onSelected: (v) =>
                          store.dispatch(DeleteTaskAction(deleteIndex: index))),
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
