import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('User')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get job => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> insertUser(UsersCompanion user) async {
    return into(users).insert(user);
  }

  Future<List<User>> getUnsyncedUsers() async {
    return (select(users)..where((tbl) => tbl.isSynced.equals(false))).get();
  }

  Future<void> markUserAsSynced(int oldId, int newId) async {
    await (update(users)..where((tbl) => tbl.id.equals(oldId))).write(
      UsersCompanion(
        id: Value(newId),
        isSynced: const Value(true),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app.db'));
    return NativeDatabase(file);
  });
}
