
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initDb() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'clocks.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE iF NOT EXISTS clocks (location TEXT NOT NULL UNIQUE, PRIMARY KEY("location"));',
      );
    },
    version: 1,
  );
  return database;
}