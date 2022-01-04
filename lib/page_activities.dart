import 'package:codelab_timetracker/page_intervals.dart';
import 'package:codelab_timetracker/page_report.dart';
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
// the old getTree()
import 'package:codelab_timetracker/requests.dart';
// has the new getTree() that sends an http request to the server
import 'dart:async';

import 'package:intl/intl.dart';
final DateFormat _dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");

class PageActivities extends StatefulWidget {
  @override
  _PageActivitiesState createState() => _PageActivitiesState();
  final int id;
  PageActivities(this.id);

}


class _PageActivitiesState extends State<PageActivities> {
  late int id;
  late Future<Tree> futureTree;
  bool selected = false;
  bool searching = false;
  late Timer _timer;
  static const int periodeRefresh = 6;

  // better a multiple of periode in TimeTracker, 2 seconds

  @override
  void initState() {
    super.initState();
    id = widget.id;
    futureTree = getTree(id);
    _activateTimer();
  }

  void _refresh() async {
    futureTree = getTree(id); // to be used in build()
    setState(() {});
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
    return FutureBuilder<Tree>(
      future: futureTree,
      // this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          return Scaffold(
            appBar: searching ? AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searching=!searching;
                  }),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 10, right: 10),
                child: TextField(
                  style: new TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  autofocus: true,
                  decoration: InputDecoration(
                    focusColor: Colors.white,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
              ),
            )
            :AppBar(
              title: const Text('TimeTracker'),
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
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      searching = !searching;
                    }),
                //TODO other actions

              ],
            )
            ,
            body: Column(
              children: [
                if (snapshot.data!.root.id != 0)
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      snapshot.data!.root.name,
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (snapshot.data!.root.id != 0)
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
                if (snapshot.data!.root.id != 0)
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
                    itemCount: snapshot.data!.root.children.length,
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

  Widget _buildRow(Activity activity, int index) {
    String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    // split by '.' and taking first element of resulting list removes the microseconds part
    if (activity is Project) {
      return Card(
        elevation: 3,
        child: ListTile(
          leading: const Icon(Icons.work_rounded),
          title: Text('${activity.name}'),
          trailing: Text('$strDuration'),
          onTap: () => _navigateDownActivities(activity.id),
        ),
      );
    } else if (activity is Task) {
      Task task = activity as Task;
      // at the moment is the same, maybe changes in the future
      Widget trailing;
      selected =activity.active;
      trailing = Text('$strDuration');
      return Card(
        elevation: 3,
        child: ListTile(
          leading: const Icon(Icons.assignment_rounded),
          title: Text('${activity.name}'),
          trailing: Wrap(
            spacing: 0,
            children: <Widget>[
              IconButton(
                icon: selected
                    ? Icon(Icons.stop)
                    : Icon(Icons.play_arrow)
                ,
                color: selected
                    ? Colors.red
                    : Colors.green,
                onPressed: () {
                  if ((activity as Task).active) {
                    stop(activity.id);
                    _refresh(); // to show immediately that task has started
                  } else {
                    start(activity.id);
                    _refresh(); // to show immediately that task has stopped
                  }
                },
              ),
              trailing
            ],
          ),
          onTap: () => _navigateDownIntervals(activity.id),
          onLongPress: () {
            if ((activity as Task).active) {
              stop(activity.id);
              _refresh(); // to show immediately that task has started
            } else {
              start(activity.id);
              _refresh(); // to show immediately that task has stopped
            }
          },
        ),


      );

    } else {
      throw(Exception("Activity that is neither a Task or a Project"));
      // this solves the problem of return Widget is not nullable because an
      // Exception is also a Widget?
    }
  }






  void _navigateDownActivities(int childId) {
    _timer.cancel();
    // we can not do just _refresh() because then the up arrow doesn't appear in the appbar
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageActivities(childId),
    )).then((var value) {
      _activateTimer();
      _refresh();
    });
    //https://stackoverflow.com/questions/49830553/how-to-go-back-and-refresh-the-previous-page-in-flutter?noredirect=1&lq=1
  }

  void _navigateDownIntervals(int childId) {
    _timer.cancel();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(childId),
    )).then((var value) {
      _activateTimer();
      _refresh();
    });
  }
}
