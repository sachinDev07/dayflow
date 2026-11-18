import 'package:drift/drift.dart';

import 'tables/app_settings.dart';
import 'tables/categories.dart';
import 'tables/notes.dart';
import 'tables/tasks.dart';

part 'app_database.g.dart';
part 'daos/task_dao.dart';
part 'daos/note_dao.dart';
part 'daos/category_dao.dart';
part 'daos/settings_dao.dart';

@DriftDatabase(
  tables: [Categories, Tasks, Notes, AppSettings],
  daos: [TaskDao, NoteDao, CategoryDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => transaction(() async {
      await m.createAll();
      await into(
        appSettings,
      ).insert(AppSettingsCompanion.insert(id: const Value(1), updatedAt: 0));
    }),
    // v1 is the first shipped schema. No destructive fallback or invented v2.
    onUpgrade: (m, from, to) async => throw UnsupportedError(
      'No migration from schema $from to $to. Keep the database and update the app.',
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );

  Future<void> initialize() async {
    await customSelect('SELECT 1').get();
  }
}
