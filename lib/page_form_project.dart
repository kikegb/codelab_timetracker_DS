import 'package:codelab_timetracker/requests.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/page_activities.dart';

import 'generated/l10n.dart';



class FormPageProject extends StatefulWidget {
  @override
  _FormPageProjectState createState() => _FormPageProjectState();
  final int id;
  FormPageProject(this.id);
}

class _FormPageProjectState extends State<FormPageProject> {
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
        title: Text('Crear Proyecto'),
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
                    print("Proyecto creado correctamente");
                    addProject(id, name.text);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PageActivities(id)),
                    );
                  } else {
                    print("Error");
                  }
                },
                color: Colors.blue,
                child: Text('Crear', style:TextStyle(color: Colors.white)),
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
          labelText: 'Introducir nombre del proyecto',
          hintText: 'Nombre',
        ),
      ),
    );
  }
}