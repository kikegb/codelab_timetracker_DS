import 'package:codelab_timetracker/page_intervals.dart';
import 'package:codelab_timetracker/page_form_project.dart';
import 'package:codelab_timetracker/page_form_task.dart';
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
// the old getTree()
import 'package:codelab_timetracker/requests.dart';
// has the new getTree() that sends an http request to the server
import 'dart:async';
import 'package:codelab_timetracker/generated/l10n.dart';
import 'package:codelab_timetracker/page_search_result.dart';
import 'package:intl/intl.dart';



class PageActivities extends StatefulWidget {
  @override
  _PageActivitiesState createState() => _PageActivitiesState();
  final int id;
  PageActivities(this.id);

}

class MenuItem {
  final String text;
  final IconData icon;

  const MenuItem({
    required this.text,
    required this.icon
  });
}

class MenuItems {
  static const List<MenuItem> itemsFirst = [
    itemProject,
    itemTask,
  ];
  static const itemProject = MenuItem(
      text: 'Crear Proyecto',
      icon: Icons.weekend_sharp,
  );
  static const itemTask = MenuItem(
      text: 'Crear Tarea',
      icon: Icons.assignment_outlined,
  );
}

class _PageActivitiesState extends State<PageActivities> {
  late int id;
  late Future<Tree> futureTree;
  bool selected = false;
  bool searching = false;
  TextEditingController txtController = TextEditingController();
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
    DateFormat _dateFormatter = DateFormat(S
        .of(context)
        .dateFormat);
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
                    searching = !searching;
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
                : AppBar(
              title: const Text('TimeTracker'),
              actions: <Widget>[
                IconButton(icon: Icon(Icons.home),
                    onPressed: () {
                      while (Navigator.of(context).canPop()) {
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
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (snapshot.data!.root.id != 0)
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Text(
                          S
                              .of(context)
                              .initialDate,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight
                              .bold),
                        ),
                        Text(
                          (snapshot.data!.root.initialDate == null ? S
                              .of(context)
                              .undefined : _dateFormatter.format(
                              snapshot.data!.root.initialDate!).toString()),
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
                        Text(
                          S
                              .of(context)
                              .finalDate,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight
                              .bold),
                        ),
                        Text(
                          (snapshot.data!.root.finalDate == null ? S
                              .of(context)
                              .undefined : _dateFormatter.format(
                              snapshot.data!.root.finalDate!).toString()),
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
            floatingActionButton: Container(
              padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  height: 80,
                  width: 80,
                  child: PopupMenuButton<MenuItem>(
                    onSelected: (item) => menuSelection(context, item),
                    itemBuilder: (context) =>
                    [
                      ...MenuItems.itemsFirst.map(buildItem).toList(),
                    ],
                    icon: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: ShapeDecoration(
                          color: Colors.blue,
                          shape: StadiumBorder(
                            side: BorderSide(color: Colors.white, width: 2),
                          )
                      ),
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a progress indicator
        return Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }

  Widget _buildRow(Activity activity, int index) {
    String strDuration = Duration(seconds: activity.duration)
        .toString()
        .split('.')
        .first;
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
      selected = activity.active;
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
                iconSize: 30.0,
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
        ),


      );
    } else {
      throw(Exception(S
          .of(context)
          .unknownActivity));
      // this solves the problem of return Widget is not nullable because an
      // Exception is also a Widget?
    }
  }


  void searchValues() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SecondRoute(txtController.text)),
    );
    searching = !searching;
  }

  void _navigateSearchedActivities(int childId) {
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

  PopupMenuItem<MenuItem> buildItem(MenuItem item) =>
      PopupMenuItem(
          value: item,
          child: Row(
            children: [
              Icon(item.icon, color: Colors.black, size: 20),
              const SizedBox(width: 12),
              Text(item.text),
            ],
          )
      );

  void menuSelection(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.itemProject:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FormPageProject(id)),
        );
        break;
      case MenuItems.itemTask:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FormPageTask(id)),
        );
        break;
    }
  }
}


