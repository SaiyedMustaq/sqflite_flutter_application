import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'my_table';
  static final userSupplier = 'userSupplierTable';

  static final USER_AREA = 'user_areas';
  static final USER_ITEM = 'user_item';
  static final USER_ITEM_SUPPLIERS = 'user_item_suppliers';
  static final USER_SUPPLIERS = 'user_suppliers';

  static final columnId = '_id';
  static final columnName = 'name';
  static final columnAge = 'age';
  static final columnPhoto = 'photo';

  static final usId = '_oid';
  static final mId = '_mId';
  static final usName = 'name';

  static final id = 'id';
  static final user_id = 'user_id';
  static final user_area_id = 'user_area_id';
  static final user_supplier_id = 'user_supplier_id';
  static final user_item_id = 'user_item_id';
  static final name = 'name';
  static final email = 'email';
  static final unit_size = 'unit_size';
  static final no_of_unit = 'no_of_unit';
  static final minimum_quantity = 'minimum_quantity';
  static final count_in = 'count_in';
  static final order_in = 'order_in';
  static final account_number = 'account_number';
  static final delivery_day = 'delivery_day';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnAge INTEGER NOT NULL,
            $columnPhoto TEXT NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $userSupplier(
            $usId INTEGER PRIMARY KEY,
            $usName TEXT NOT NULL,
            $mId INTEGER NOT NULL,
            FOREIGN KEY($mId) REFERENCES $table ($columnId)
          )
        ''');

    await db.execute('''
          CREATE TABLE $USER_AREA(
            $id INTEGER NOT NULL,
            $user_id INTEGER NOT NULL,
            $name TEXT NOT NULL
            )
        ''');
    await db.execute('''
          CREATE TABLE $USER_SUPPLIERS(
            $id INTEGER NOT NULL,
            $user_id INTEGER NOT NULL,
            $name TEXT NOT NULL,
            $email TEXT NOT NULL,
            $account_number TEXT NOT NULL,
            $delivery_day TEXT NOT NULL
            )
        ''');
    await db.execute('''
          CREATE TABLE $USER_ITEM (
            $id INTEGER NOT NULL,
            $user_id INTEGER NOT NULL,
            $name TEXT NOT NULL,
            $unit_size TEXT NOT NULL,
            $no_of_unit TEXT NOT NULL,
            $minimum_quantity TEXT NOT NULL,
            $count_in TEXT NOT NULL,
            $order_in TEXT NOT NULL,
            $user_area_id INTEGER NOT NULL,
            $user_supplier_id INTEGER NOT NULL,
            FOREIGN KEY($user_area_id) REFERENCES $USER_AREA ($id),
            FOREIGN KEY($user_supplier_id) REFERENCES $USER_SUPPLIERS ($id)
            )
        ''');

    await db.execute('''
          CREATE TABLE $USER_ITEM_SUPPLIERS (
            $id INTEGER NOT NULL,
            $user_id INTEGER NOT NULL,
            $user_item_id INTEGER NOT NULL,
            $user_supplier_id INTEGER NOT NULL,
            FOREIGN KEY($user_item_id) REFERENCES $USER_ITEM ($id),
            FOREIGN KEY($user_supplier_id) REFERENCES $USER_SUPPLIERS ($id)
            )
        ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await database;
    return await db!.insert(table, row);
  }

  Future<int> insertSupplier(Map<String, dynamic> row) async {
    Database? db = await database;
    return await db!.insert(userSupplier, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.

  Future<List<Map<String, dynamic>>> getAll() async {
    Database? db = await database;
    return await db!.query(table);
  }

  Future<List<Map<String, dynamic>>> getAllSupplier() async {
    Database? db = await database;
    return await db!.query(userSupplier);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database? db = await database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database? db = _database;
    int id = row[columnId];
    return await db!
        .update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database? db = await database;
    return await db!.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
