import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

class NewClockPage extends StatefulWidget {
  const NewClockPage({super.key});

  @override
  State<NewClockPage> createState() => _NewClockPageState();
}

class _NewClockPageState extends State<NewClockPage> {
  String currentTimezone = '';
  Map<String, Location> locations = <String, Location>{};

  @override
  void initState() {
    super.initState();
    locations = timeZoneDatabase.locations;
    FlutterTimezone.getLocalTimezone().then((value) {
      currentTimezone = value;      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Clock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: LocationSearchDelegate(currentTimezone, []));
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: locations.length,
        prototypeItem: ListTile(title: Text(locations.keys.first)),
        itemBuilder: (context, index) {
          final location = locations.keys.elementAt(index);
          return location == currentTimezone ? ListTile(
            title: Text(location),
            selected: true,
          ) : ListTile(
            title: Text(location),
            selected: false,
          );
        },
      ),
    );
  }
}

class LocationSearchDelegate extends SearchDelegate {
  String currentTimezone = '';
  List<String> searchResults = [];
  List<String> excludeList = [];
  LocationSearchDelegate (String tz, List<String> zones) {
    currentTimezone = tz;
    excludeList = zones;
    searchResults = timeZoneDatabase.locations.keys.toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = '';
        }
      },
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => Center(
    child: Text(
      query,
      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
    ),
  );

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = searchResults
      .where((searchResult) => !excludeList.contains(searchResult) && searchResult.toLowerCase().contains(query.toLowerCase()))
      .toList();
    debugPrint('${suggestions.length}');

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        if (suggestions.isEmpty) {
          return const ListTile(
            title: Text('No results'),
          );
        }
        final suggestion = suggestions[index];

        return ListTile(
          title: Text(suggestion),
          onTap: () {
            Navigator.pop(context, suggestion);
          },
        );
      },
    );
  }

}

class MyClockPage extends StatefulWidget {
  const MyClockPage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _MyClockPageState();
}

class _MyClockPageState extends State<MyClockPage> {
  late String currentTimezone = '';
  late Timer? timer;
  late Location? _location;
  late String timezone = '';
  late String currentDate = '';
  late String currentTime = '';
  late String locale = '';
  late int tzOffsetHours = 0;
  late String tzName = '';
  late DateTime tzdt;

  @override
  void initState() {
    super.initState();
    locale = Platform.localeName;
    _location = getLocation(widget.title);
    
    // location?.zones.elementAt(0)
    /* timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final now = DateTime.now();
      currentDate = DateFormat('EEEE, MMMM d, y').format(now);
      currentTime = DateFormat.jms().format(now);
    }); */
    FlutterTimezone.getLocalTimezone().then((value) {
      final now = DateTime.now();
      if (widget.title == value) {
        tzdt = now;
        tzName = now.timeZoneName;
        tzOffsetHours = now.timeZoneOffset.inHours;
        currentDate = DateFormat('EEEE, MMMM d, y').format(now);
        currentTime = DateFormat.jms().format(now);
      } else {
        final zone = TZDateTime.from(now, _location!);
        tzdt = zone;
        tzName = zone.timeZoneName;
        tzOffsetHours = zone.timeZoneOffset.inHours;
        currentDate = DateFormat('EEEE, MMMM d, y').format(zone);
        currentTime = DateFormat.jms().format(zone);
      }
      setState(() {
        currentTimezone = value;
      });
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        final now = DateTime.now();
        setState(() {
          if (widget.title == value) {
            tzdt = now;
            tzOffsetHours = now.timeZoneOffset.inHours;
            currentDate = DateFormat('EEEE, MMMM d, y').format(now);
            currentTime = DateFormat.jms().format(now);
          } else {
            final zone = TZDateTime.from(now, _location!);
            tzdt = zone;
            tzOffsetHours = zone.timeZoneOffset.inHours;
            currentDate = DateFormat('EEEE, MMMM d, y').format(zone);
            currentTime = DateFormat.jms().format(zone);
          }
        });
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Text(currentDate, style: const TextStyle(fontSize: 32)),
            Text('$currentTime $tzName', style: const TextStyle(fontSize: 32)),
            Text('UTC${tzOffsetHours > 0 ? '+$tzOffsetHours' : tzOffsetHours}', style: const TextStyle(fontSize: 32)),
            Text('DST: ${_location?.currentTimeZone.isDst}', style: const TextStyle(fontSize: 32)),
            Text(locale, style: const TextStyle(fontSize: 32)),
          ],
        ),
      ),
    );
  }

}