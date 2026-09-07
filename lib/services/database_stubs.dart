import 'dart:async';

/// Web ortamında sqflite kütüphanesi derleme hatası vermesin diye oluşturulan stub.
class Database {
  Future<void> close() async {}
  bool get isOpen => false;
  Future<int> insert(String table, Map<String, dynamic> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async => 0;
  Future<List<Map<String, dynamic>>> query(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) async => [];
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) async => 0;
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async => 0;
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async => 0;
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async => [];
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}
  Batch batch() => Batch();
}

class Batch {
  void insert(String table, Map<String, dynamic> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {}
  void update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) {}
  void delete(String table, {String? where, List<Object?>? whereArgs}) {}
  void execute(String sql, [List<Object?>? arguments]) {}
  void rawInsert(String sql, [List<Object?>? arguments]) {}
  void rawUpdate(String sql, [List<Object?>? arguments]) {}
  void rawDelete(String sql, [List<Object?>? arguments]) {}
  Future<List<dynamic>> commit({bool? exclusive, bool? noResult, bool? continueOnError}) async => [];
}

enum ConflictAlgorithm { rollback, abort, fail, ignore, replace }

class Sqflite {
  static int? firstIntValue(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return null;
    return list.first.values.first as int?;
  }
}

Future<String> getDatabasesPath() async => '';
Future<Database> openDatabase(String path, {int? version, FutureOr<void> Function(Database, int)? onCreate, FutureOr<void> Function(Database, int, int)? onUpgrade}) async => Database();
