import 'dart:async';
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
        _database =
            await openDatabase('database.db', version: 1, onCreate: _create);
      } else {
        databaseFactory = databaseFactory;
        final directory = await getApplicationDocumentsDirectory();
        var path = join(directory.path, 'database.db');
        _database = await openDatabase(path, version: 1, onCreate: _create);
      }
      // String path = join('assets', 'db');
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

    return await db.rawQuery(sql, arguments);
  }

  /// <summary>
  /// Adds a new category and returns true if the category
  /// does not already exist; otherwise, false.
  /// Tested, Working
  /// </summary>
  Future<bool> addCategory(String name) async {
    var resp = await TodoDB().executeQuery(
        "INSERT INTO todo_category(name) VALUES (?) "
        "ON CONFLICT DO NOTHING RETURNING 1;",
        [name]);
    return resp.length != 0;
  }

  /// <summary>
  /// renames the name of the category inside the database.
  /// Tested, working
  /// </summary>
  Future<bool> renameCategory(String oldName, String newName) async {
    var resp = await executeQuery(
        "UPDATE todo_category SET name=? "
        "WHERE name=? AND NOT EXISTS (SELECT * FROM todo_category WHERE name=?)"
        "RETURNING *",
        [newName, oldName, newName]);
    return resp.length != 0;
  }

  /// <summary>
  /// Deletes a category from the database.
  /// Tested, working
  /// </summary>
  Future<void> deleteCategory(String name) async {
    await executeQuery("DELETE FROM todo_category WHERE name=?;", [name]);
  }

  /// <summary>
  /// Adds an item to the database by the given category.
  /// Tested, working
  /// </summary>
  Future<bool> addItem(String name, String categoryName) async {
    dynamic resp = await executeQuery(
        "INSERT INTO todo_item (for_category, name) "
        "SELECT cid, ? FROM todo_category WHERE name=? "
        "ON CONFLICT DO NOTHING RETURNING 1;",
        [name, categoryName]);
    return resp.length != 0;
  }

  /// <summary>
  /// Updates the given fields in the item
  /// Tested, working
  /// </summary>
  Future<bool> updateItem(
      String name, String categoryName, Map<String, dynamic> items) async {
    List<String> keys = items.keys.toList();
    List<dynamic> values = items.values.toList();
    String statement = "UPDATE todo_item SET ";
    var unchangeables = ["name", "iid", "for_category"];
    for (int i = 0; i < keys.length; i++) {
      if (unchangeables.contains(keys[i])) continue;
      statement += '${keys[i]}=?${i != keys.length - 1 ? ', ' : ' '}';
    }
    statement += 'WHERE name=? AND for_category='
        '(SELECT cid FROM todo_category WHERE name=?)'
        ' RETURNING *';
    dynamic resp =
        await executeQuery(statement, [...values, name, categoryName]);
    return resp.length != 0;
  }

  /// <summary>
  /// Renames a todo item for the given category and returns true if successful
  /// Tested, working
  /// </summary>
  Future<bool> renameItem(String name, String category, String newName) async {
    var resp = await executeQuery(
        "UPDATE todo_item SET name=? "
        "WHERE name=? AND for_category=(SELECT cid FROM todo_category WHERE name=?)"
        " AND NOT EXISTS (SELECT * FROM todo_item WHERE name=? AND for_category=("
        "SELECT cid FROM todo_category WHERE name=?)) RETURNING *",
        [newName, name, category, newName, category]);
    return resp.length != 0;
  }

  /// <summary>
  /// Deletes an item from the database.
  /// Tested, working
  /// </summary>
  Future<void> deleteItem(String name, String categoryName) async {
    await executeQuery(
        "DELETE FROM todo_item WHERE "
        "name=? AND for_category="
        "(SELECT cid FROM todo_category WHERE name=?);",
        [name, categoryName]);
  }

  /// Tested, working
  Future<bool> addReminder(
      String name, String categoryName, int reminder) async {
    var resp = await executeQuery(
        "INSERT INTO todo_reminders (for_item, reminder_time) "
        "SELECT i.iid, ? FROM todo_item i, todo_category s "
        "WHERE s.name=? AND i.name=? AND i.for_category=s.cid"
        " ON CONFLICT DO NOTHING RETURNING 1",
        [reminder, categoryName, name]);
    return resp.length != 0;
  }

  /// Tested, working
  Future<void> deleteReminder(
      String category, String name, int reminder) async {
    await executeQuery(
        "DELETE FROM todo_reminders WHERE for_item = "
        "(SELECT i.iid FROM todo_item i, todo_category c"
        " WHERE c.name=? AND i.name=? AND c.cid=i.iid) AND reminder_time=?",
        [category, name, reminder]);
  }

  /// Tested, working
  Future<List<dynamic>> getCategories() async {
    dynamic resp = await executeQuery("SELECT name FROM todo_category");
    return resp.toList();
  }

  /// Tested, working
  Future<List<dynamic>> getItems(String category) async {
    dynamic resp = await executeQuery(
        "SELECT i.* FROM todo_item i, todo_category c WHERE i.for_category=c.cid AND c.name=?;",
        [category]);
    return resp.toList();
  }

  /// Tested, working
  Future<List<dynamic>> getReminders(String category, String item) async {
    dynamic resp = await executeQuery(
        "SELECT reminder_time FROM todo_reminders r, todo_item i, todo_category c WHERE c.name=? AND i.name=? AND i.for_category=c.cid AND r.for_item = i.iid;",
        [category, item]);
    return resp.toList();
  }

  /// Tested, working
  Future<dynamic> getItem(String name, String cat) async {
    dynamic resp = await executeQuery(
        "SELECT i.* FROM todo_item i, todo_category c "
        "WHERE i.name=? AND c.name=? AND i.for_category=c.cid;",
        [name, cat]);
    if (resp.length == 0) return null;
    return resp[0];
  }

  /// Tested, working
  Future<List<dynamic>> searchItem(String name) async {
    dynamic resp = await executeQuery(
        "SELECT i.*, c.name AS category FROM todo_item i, todo_category c "
        "WHERE i.for_category=c.cid AND LOWER(i.name) LIKE ?",
        ["%$name%".toLowerCase()]);
    return resp;
  }
}
