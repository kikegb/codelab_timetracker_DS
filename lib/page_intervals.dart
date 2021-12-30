import 'dart:async';
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/page_activities.dart';
import 'package:codelab_timetracker/tree.dart' as Tree hide getTree;
// to avoid collision with an Interval class in another library
import 'package:codelab_timetracker/requests.dart';
import 'package:intl/intl.dart';
final DateFormat _dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");

class PageIntervals extends StatefulWidget {
  final int id;
  PageIntervals(this.id);
  @override
  _PageIntervalsState createState() => _PageIntervalsState();
}

class _PageIntervalsState extends State<PageIntervals> {
  late int id;
  late Future<Tree.Tree> futureTree;
  late Timer _timer;
  static const int periodeRefresh = 6;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    futureTree = getTree(id);
    _activateTimer();
  }

  void _activateTimer() {
    _timer = Timer.periodic(Duration(seconds: periodeRefresh), (Timer t) {
      futureTree = getTree(id);
      setState(() {});
    });
  }

  @override
  void dispose() {
    // "The framework calls this method when this State object will never build again"
    // therefore when going up
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree.Tree>(
      future: futureTree,
      // this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          int numChildren = snapshot.data!.root.children.length;
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data!.root.name),
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
            body: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    snapshot.data!.root.name,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      const Text(
                        "Initial date: ",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        (snapshot.data!.root.initialDate == null? 'undefined' : _dateFormatter.format(snapshot.data!.root.initialDate!).toString()),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      const Text(
                        "Final date: ",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        (snapshot.data!.root.finalDate == null? 'undefined' : _dateFormatter.format(snapshot.data!.root.finalDate!).toString()),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 400,
                  child: ListView.separated(
                    // it's like ListView.builder() but better because it includes a separator between items
                    padding: const EdgeInsets.all(16.0),
                    itemCount: numChildren,
                    itemBuilder: (BuildContext context, int index) =>
                        _buildRow(snapshot.data!.root.children[index], index),
                    separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a progress indicator
        return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }

  Widget _buildRow(Tree.Interval interval, int index) {
    String strDuration = Duration(seconds: interval.duration)
        .toString()
        .split('.')
        .first;
    String strInitialDate = interval.initialDate.toString().split('.')[0];
    // this removes the microseconds part
    String strFinalDate = interval.finalDate.toString().split('.')[0];
    return ListTile(
      title: Text('From ${strInitialDate}\nTo ${strFinalDate}'),
      trailing: Text('$strDuration'),
    );
  }
}

