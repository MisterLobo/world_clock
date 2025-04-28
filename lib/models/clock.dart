import 'package:flutter/material.dart';
import 'package:world_clock/db.dart';

class Clock {
  final String location;

  const Clock({required this.location});

  Map<String, Object?> toMap() => { 'location': location };

  @override
  String toString() => 'Clock{location: $location}';
}

Future<void> insertClock(Clock clock) async {
  final db = await initDb();
  int id = await db.rawInsert('INSERT INTO clocks(location) VALUES(?)', [clock.location]);
  await db.close();
  debugPrint('ID: $id');
}

Future<List<Map>> getClocks() async {
  final db = await initDb();
  List<Map> clocks = await db.rawQuery('SELECT * FROM clocks');
  await db.close();
  return clocks;
}

Future<int> removeClock(String location) async {
  final db = await initDb();
  final count = await db.rawDelete('DELETE FROM clocks WHERE location = ?', [location]);
  await db.close();
  return count;
}