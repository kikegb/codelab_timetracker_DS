import 'package:flutter/material.dart';



class SecondRoute extends StatelessWidget {
  String searchedString;

  SecondRoute(this.searchedString);

  @override
  Widget build(BuildContext context) {
    String resultsString = 'Results for: ' + this.searchedString;
    return Scaffold(
      appBar: AppBar(
        title: Text(searchedString),
      ),
      body: Center(
        child: ListView(
          // it's like ListView.builder() but better because it includes a separator between items
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(resultsString, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.assignment_rounded),
                title: Text('Tarea 4'),
                trailing: Text(Duration(seconds: 0).toString().split('.').first),
              ),
            ),
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.work_rounded),
                title: Text('Proyecto 1'),
                trailing: Text(Duration(seconds: 0).toString().split('.').first),
              ),
            )
            ,Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.work_rounded),
                title: Text('Proyecto 2'),
                trailing: Text(Duration(seconds: 0).toString().split('.').first),
              ),
            )
          ],
        ),
      ),
    );
  }
}
