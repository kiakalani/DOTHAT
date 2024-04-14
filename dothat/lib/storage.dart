import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class TodoDB {
  /// For implementation of singleton for database
  Database? _database;
  TodoDB._internal();
  static TodoDB? _db;
  factory TodoDB() {
    if (_db == null) {
      _db = TodoDB._internal();
      print('Ye');
      _db!._initDb();
    }
    return _db!;
  }

  ///<summary>
  /// Creates the initial database based
  /// on the provided schema to it.
  ///</summary>
  Future _create(Database db, int version) async {
    String schema = await _readSchema();
    await db.execute(schema);
  }

  ///<summary>
  /// Initializes the database instance.
  ///</summary>
  Future<Database> _initDb() async {
    if (_database == null) {
      // print('B4');
      // await getApplicationDocumentsDirectory();
      // print('Yay');
      if (kIsWeb) {
        databaseFactory = databaseFactoryFfiWeb;
      } else {
        databaseFactory = databaseFactory;
      }
      // String path = join('assets', 'db');
      _database =
          await openDatabase('database.db', version: 1, onCreate: _create);
      print('Done?');
    }
    return _database!;
  }

  ///<summary>
  /// Reads the schema from the assets folder
  ///</summary>
  Future<String> _readSchema() async {
    return await rootBundle.loadString('assets/schema.sql');
  }

  /// <summary>
  /// Executes the query statement
  /// </summary>
  Future<dynamic> executeQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await _initDb();

    print('Got here');
    return await db.rawQuery(sql, arguments);
  }
}
