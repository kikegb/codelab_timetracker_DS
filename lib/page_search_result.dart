import 'package:flutter/material.dart';



class SecondRoute extends StatelessWidget {
  String something;

  SecondRoute(this.something);

  @override
  Widget build(BuildContext context) {
    String something2 = 'No result found for:' + this.something +
        '\nClick to go back';
    return Scaffold(
      appBar: AppBar(
        title: Text(something),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(something2),
        ),
      ),
    );
  }
}
