import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/page_activities.dart';
import 'package:codelab_timetracker/page_search_result.dart';
import 'package:codelab_timetracker/tree.dart' as Tree hide getTree;
// to avoid collision with an Interval class in another library
import 'package:codelab_timetracker/requests.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:codelab_timetracker/generated/l10n.dart';
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
  bool searching = false;
  TextEditingController txtController = TextEditingController();
  static const int periodeRefresh = 6;
  bool isSwitched = false;
  bool viewCalendar = false;

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
                  controller: txtController,
                  onEditingComplete: () {
                    searchValues();
                  },
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

              ],
            ),
            body: Column(
              children: [
                Row(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        snapshot.data!.root.name,
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(100, 0, 0, 0),
                      
                      child: IconButton(
                        iconSize: 50.0,
                        icon: (snapshot.data!.root as Tree.Task).active
                            ? Icon(Icons.stop)
                            : Icon(Icons.play_arrow)
                        ,
                        color: (snapshot.data!.root as Tree.Task).active
                            ? Colors.red
                            : Colors.green,
                        onPressed: () {
                          if ((snapshot.data!.root as Tree.Task).active) {
                            stop(snapshot.data!.root.id);
                            _refresh(); // to show immediately that task has started
                          } else {
                            start(snapshot.data!.root.id);
                            _refresh(); // to show immediately that task has stopped
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text(
                        S.of(context).initialDate,
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
                       Text(
                        S.of(context).finalDate,
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
                  child: SfCalendar(
                    view: CalendarView.schedule,
                    firstDayOfWeek: 1,
                    dataSource: MeetingDataSource(_buildIntervals(snapshot.data!.root.children))
                  )
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
  void searchValues(){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) =>  SecondRoute(txtController.text)),
    );
    searching=!searching;
  }

  List<Appointment> _buildIntervals(List<dynamic> children){
    List<Appointment> intervals = <Appointment>[];
    for(int i = 0; i < children.length; i++){
      DateTime init = children[i].initialDate!;
      DateTime end = children[i].finalDate!;
      intervals.add(Appointment(startTime: init, endTime: end));
    }
    return intervals;
  }

  void _refresh() async {
    futureTree = getTree(id); // to be used in build()
    setState(() {});
  }
}



class MeetingDataSource extends CalendarDataSource{
  MeetingDataSource(List<Appointment> source){
    appointments = source;
  }
}
