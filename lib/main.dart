import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_slidable/flutter_slidable.dart';

import 'models/clock.dart';
import 'my_clock.dart';
import 'search.dart';

void main() {
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Clock',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'World Clock'),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(useMaterial3: true),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String currentTimezone = '';
  Map<String, Location> locations = <String, Location>{};
  Timer? timer;
  int seconds = 0;
  DateTime nowdt = DateTime.now();
  late String currentDate = '';
  late String currentTime = '';
  final List<String> zones = [];

  @override
  void initState() {
    super.initState();
    locations = timeZoneDatabase.locations;
    getLocalTZ();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        nowdt = DateTime.now();
        currentTime = DateFormat.Hms().format(nowdt);
        currentDate = DateFormat.MMMMEEEEd().format(nowdt);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void getLocalTZ() {
    FlutterTimezone
      .getLocalTimezone()
      .then((value) {
        currentTimezone = value;
        return getClocks();
      })
      .then((clocks) {
        for (var clock in clocks) {
          final clk = Clock(location: clock.values.first);
          zones.add(clk.location);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('My Clocks'),
            ),
            ...zones.map((zone) => ListTile(
              title: Text(zone),
              onTap: () {},
            )),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Column(
                children: [
                  Text(
                    currentTime,
                    style: const TextStyle(fontSize: 48),
                  ),
                  Text(currentDate),
                  Text(
                    'Current: $currentTimezone',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15.0),
              shrinkWrap: true,
              itemCount: zones.length,
              itemBuilder: (context, index) => Slidable(
                key: ValueKey(index),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.red,
                      icon: Icons.delete,
                      onPressed: (BuildContext context) {
                        final clock = zones.elementAt(index);
                        zones.remove(clock);
                        removeClock(clock);
                      },
                    ),
                  ],
                ),
                child: ClockListItem(
                  timezone: zones.elementAt(index),
                  currentTimezone: currentTimezone,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateAndAddSelection(context);
        },
        tooltip: 'Add Clock',
        child: const Icon(Icons.add),
      ), 
    );
  }

  Future<void> _navigateAndAddSelection(BuildContext context) async {
    final result = await showSearch(
      context: context, 
      delegate: LocationSearchDelegate(currentTimezone, zones),
    );

    if (!context.mounted) return;

    if (result != null) {
      zones.add(result.toString());
      insertClock(Clock(location: result.toString()));
    }
  }
}

class ClockListItem extends StatefulWidget {
  const ClockListItem({super.key, required this.timezone, required this.currentTimezone});

  final String currentTimezone;
  final String? timezone;

  @override
  State<StatefulWidget> createState() => _ClockListItemState();
}

class _ClockListItemState extends State<ClockListItem> {
  String timezone = '';
  String currentDate = '';
  String currentTime = '';

  void getDateTime() {
    if (widget.timezone == null || widget.timezone == '') return;
    if (timeZoneDatabase.locations.keys.contains(widget.timezone)) {
      Location tzLocation = getLocation(widget.timezone!);
      final now = DateTime.now();
      final tzDateTime = TZDateTime.from(now, tzLocation);
      currentDate = DateFormat.yMd().format(tzDateTime);
      currentTime = DateFormat.jm().format(tzDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    getDateTime();
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.black.withAlpha(30),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => MyClockPage(title: '${widget.timezone}'))
          );
        },
        child: SizedBox(
          height: 75,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('${widget.timezone} ${widget.timezone == widget.currentTimezone ? "(current)" : ""}'),
                subtitle: Text('$currentDate $currentTime'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}