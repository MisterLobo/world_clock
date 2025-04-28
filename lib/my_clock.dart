import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';

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
            Text('UTC${tzOffsetHours > 0 ? '+$tzOffsetHours' : (tzOffsetHours < 0 ? tzOffsetHours : "")}', style: const TextStyle(fontSize: 32)),
            Text('DST: ${_location?.currentTimeZone.isDst}', style: const TextStyle(fontSize: 32)),
            Text(locale, style: const TextStyle(fontSize: 32)),
          ],
        ),
      ),
    );
  }

}
