import 'package:codelab_timetracker/requests.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/page_activities.dart';



class FormPageTask extends StatefulWidget {
  @override
  _FormPageTaskState createState() => _FormPageTaskState();
  final int id;
  FormPageTask(this.id);
}

class _FormPageTaskState extends State<FormPageTask> {
  late int id;
  late Future<Tree> futureTree;
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();

  @override
  void initState() {
    super.initState();
    id = widget.id;
    futureTree = getTree(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).create_task),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.home),
              onPressed: () {
                while(Navigator.of(context).canPop()) {
                  print("pop");
                  Navigator.of(context).pop();
                }
                /* this works also:
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                      */
                PageActivities(0);
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _crearInputNom(),

              FlatButton(
                onPressed: () {
                  if(_formKey.currentState!.validate()) {
                    print("Tarea creado correctamente");
                    addTask(id, name.text);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PageActivities(id)),
                    );
                  } else {
                    print("Error");
                  }
                },
                color: Colors.blue,
                child: Text((S.of(context).create), style:TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _crearInputNom() {
    return Container(
      padding: EdgeInsets.all(15),
      child: TextFormField(
        controller: name,
        validator: (value) => value!.isEmpty ? "campo requerido" : null,
        decoration: InputDecoration(
          labelText: (S.of(context).Itask),
          hintText: (S.of(context).Name),
        ),
      ),
    );
  }
}
