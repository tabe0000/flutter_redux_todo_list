import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  final List<String> todoTasks;
  AppState(this.todoTasks);
}

class AddTaskAction {
  final String newTask;
  AddTaskAction({this.newTask});
}

AppState reducer(AppState prev, action) {
  if (action is AddTaskAction) {
    print("im add action reducer.");
    print(action.newTask);
    return AppState(addTaskReducer(prev, action.newTask));
  }
}

List<String> addTaskReducer(AppState prev, String newTask) {
  return []
    ..addAll(prev.todoTasks)
    ..add(newTask);
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

  _displayDialog(BuildContext context, Store<AppState> store) async {
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
                            onSubmitted: (task) => 
                                store.dispatch(AddTaskAction(newTask: task))),
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
                  title: Text(todoTasks[index]),
                );
              }),
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(context, store),
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
