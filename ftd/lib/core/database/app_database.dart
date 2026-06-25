import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class PendingPings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  IntColumn get timestamp => integer()(); // unix seconds
  RealColumn get speed => real()();
  RealColumn get bearing => real()();
  RealColumn get altitude => real()();
  RealColumn get accuracy => real()();
}

@DriftDatabase(tables: [PendingPings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forBackground(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  Future<List<PendingPing>> pendingFor(String deviceId) =>
      (select(pendingPings)
            ..where((t) => t.deviceId.equals(deviceId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  Future<int> countPending(String deviceId) async {
    final count = pendingPings.id.count();
    final query = selectOnly(pendingPings)
      ..addColumns([count])
      ..where(pendingPings.deviceId.equals(deviceId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> enqueue(PendingPingsCompanion entry) =>
      into(pendingPings).insert(entry);

  Future<void> dequeue(int id) =>
      (delete(pendingPings)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ftd_queue.db');
    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
