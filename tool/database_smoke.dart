// Developer-only real-device persistence check, never a product route.
import 'dart:io';

import 'package:dayflow/core/utils/local_date.dart';
import 'package:dayflow/database/app_database.dart';
import 'package:dayflow/database/database_connection.dart';
import 'package:dayflow/database/write_metadata.dart';
import 'package:dayflow/features/tasks/data/sqlite_task_repository.dart';
import 'package:dayflow/features/tasks/domain/task_entity.dart';
import 'package:dayflow/features/notes/data/sqlite_note_repository.dart';
import 'package:dayflow/features/notes/domain/note_entity.dart';
import 'package:dayflow/features/settings/data/sqlite_category_repository.dart';
import 'package:dayflow/features/settings/domain/category_entity.dart';
import 'package:material_ui/material_ui.dart';

void require(bool value, String description) {
  if (!value) throw StateError(description);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppDatabase? db;
  String? taskId;
  String? noteId;
  String? categoryId;
  var result = 'M3 database verification failed';
  try {
    final metadata = WriteMetadata();
    db = openAppDatabase();
    await db.initialize();
    final version =
        (await db
                .customSelect('SELECT sqlite_version() AS version')
                .getSingle())
            .read<String>('version');
    final date = LocalDate(2026, 11, 18);
    final category = await SqliteCategoryRepository(db, metadata).create(
      CategoryInput(name: 'M3 smoke ${metadata.newId()}', color: 0xA98AFF),
    );
    categoryId = category.id;
    final task = await SqliteTaskRepository(db, metadata).create(
      TaskInput(
        title: 'M3 temporary persistence check',
        scheduledDate: date,
        categoryId: category.id,
      ),
    );
    taskId = task.id;
    final note = await SqliteNoteRepository(
      db,
      metadata,
    ).create(NoteInput(content: 'M3 temporary note', linkedTaskId: task.id));
    noteId = note.id;
    await db.close();
    db = null;
    db = openAppDatabase();
    final restored = await SqliteTaskRepository(db, metadata).get(task.id);
    require(restored?.title == task.title, 'Task did not persist');
    require(restored?.scheduledDate == date, 'Calendar date changed');
    require(
      (await SqliteNoteRepository(db, metadata).get(note.id))?.linkedTaskId ==
          task.id,
      'Note relationship did not persist',
    );
    require(
      await File(await DatabaseStorage.path()).exists(),
      'Database file missing',
    );
    require(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
            'user_version',
          ) ==
          1,
      'Schema version mismatch',
    );
    require(
      (await db.customSelect('PRAGMA foreign_keys').getSingle()).read<int>(
            'foreign_keys',
          ) ==
          1,
      'Foreign keys disabled',
    );
    result =
        'M3 SQLite verification passed\nSQLite $version\nSchema 1\n'
        'Tasks and notes persisted across connection restart.';
  } catch (error, stack) {
    debugPrint('M3_DATABASE_SMOKE_FAIL: $error\n$stack');
    result = 'M3 database verification failed\n$error';
  } finally {
    if (db == null &&
        (taskId != null || categoryId != null || noteId != null)) {
      db = openAppDatabase();
    }
    try {
      // Delete only the UUIDs created by this invocation, children before parents.
      if (db != null) {
        await db.transaction(() async {
          if (noteId != null) {
            await db!.customStatement('DELETE FROM notes WHERE id = ?', [
              noteId,
            ]);
          }
          if (taskId != null) {
            await db!.customStatement('DELETE FROM tasks WHERE id = ?', [
              taskId,
            ]);
          }
          if (categoryId != null) {
            await db!.customStatement('DELETE FROM categories WHERE id = ?', [
              categoryId,
            ]);
          }
        });
        final integrity =
            (await db.customSelect('PRAGMA integrity_check').getSingle())
                .read<String>('integrity_check');
        require(integrity == 'ok', 'SQLite integrity check failed');
      }
    } finally {
      await db?.close();
    }
  }
  if (result.startsWith('M3 SQLite verification passed')) {
    debugPrint('M3_DATABASE_SMOKE_PASS: $result; temporary fixtures removed.');
  }
  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(result),
          ),
        ),
      ),
    ),
  );
}
