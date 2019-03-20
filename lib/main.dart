import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(App());


class App extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _todoList = [];
  final _taskController = TextEditingController();
  Map<String,dynamic> _lastRemoved;
  int _lastIndexRemoved;


  @override
  void initState() {
    super.initState();

     _readData().then((data){
         setState(() {
           this._todoList = json.decode(data);
         });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 7.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                          labelText: 'Lista de tarefas',
                          labelStyle: TextStyle(color: Colors.blueAccent)
                      ),
                    )
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("Add"),
                  textColor: Colors.white,
                  onPressed: addTask,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top:7.0),
              itemCount: _todoList.length,
              itemBuilder:buildItens,
            ),
          )
        ],
      )
    );
  }

  Widget buildItens (context,index){
    return  Dismissible(
      key:Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(Icons.delete,color: Colors.white),
        )
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_todoList[index]['nome']),
        value:_todoList[index]['check'],
        secondary: Icon(_todoList[index]['check']?Icons.check:Icons.info),
        onChanged: (c){
          setState(() {
            _todoList[index]['check']=c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastIndexRemoved = index;
          _todoList.removeAt(index);

          _saveData();

          final snackBar = SnackBar(
            content: Text("Tarefa ${_lastRemoved['nome']} foi removida"),
            action: SnackBarAction(label: "Desfazer",
                onPressed: (){
                  setState(() {
                    _todoList.insert(_lastIndexRemoved, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 2)
          );

          Scaffold.of(context).showSnackBar(snackBar);
        });

      },
    );
  }


  void addTask(){
    setState(() {
      Map<String,dynamic> task = new Map();
      task['nome'] = _taskController.text;
      _taskController.text = '';
      task['check'] = false;

      _todoList.add(task);
      _saveData();
    });
  }

  Future<File> _getFile() async{
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/task.json");
  }

  Future<File> _saveData() async{
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async{

    try{
      final file = await _getFile();

      return file.readAsString();

    }catch(e){
      return null;
    }
  }

}



