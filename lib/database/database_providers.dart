import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/tasks/data/sqlite_task_repository.dart';
import '../features/tasks/domain/task_repository.dart';
import '../features/notes/data/sqlite_note_repository.dart';
import '../features/notes/domain/note_repository.dart';
import '../features/settings/data/sqlite_category_repository.dart';
import '../features/settings/domain/category_repository.dart';
import '../features/settings/data/sqlite_settings_repository.dart';
import '../features/settings/domain/settings_repository.dart';
import 'app_database.dart';
import 'database_connection.dart';
import 'write_metadata.dart';

/// One lazily-opened connection per app ProviderScope. Tests may override it.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = openAppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});
final writeMetadataProvider = Provider<WriteMetadata>((ref) => WriteMetadata());
final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => SqliteTaskRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(writeMetadataProvider),
  ),
);
final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => SqliteNoteRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(writeMetadataProvider),
  ),
);
final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => SqliteCategoryRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(writeMetadataProvider),
  ),
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SqliteSettingsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(writeMetadataProvider),
  ),
);
