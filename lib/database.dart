import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HistoryDatabase {
  static final HistoryDatabase _instance = HistoryDatabase._internal();
  factory HistoryDatabase() => _instance;
  HistoryDatabase._internal();

  late final Database database;

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE entry(id INTEGER PRIMARY KEY AUTOINCREMENT, operation TEXT, date INT)');
  }

  open() async {
    database = await openDatabase(
        join(await getDatabasesPath(), 'history.db'),
        version: 1,
        onCreate: _onCreate);
  }

}