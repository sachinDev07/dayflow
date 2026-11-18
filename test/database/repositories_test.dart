import 'dart:io';

import 'package:dayflow/core/utils/local_date.dart';
import 'package:dayflow/core/utils/reminder_instant.dart';
import 'package:dayflow/database/app_database.dart';
import 'package:dayflow/database/database_providers.dart';
import 'package:dayflow/database/write_metadata.dart';
import 'package:dayflow/features/tasks/data/sqlite_task_repository.dart';
import 'package:dayflow/features/tasks/domain/task_entity.dart';
import 'package:dayflow/features/notes/data/sqlite_note_repository.dart';
import 'package:dayflow/features/notes/domain/note_entity.dart';
import 'package:dayflow/features/settings/data/sqlite_category_repository.dart';
import 'package:dayflow/features/settings/data/sqlite_settings_repository.dart';
import 'package:dayflow/features/settings/domain/category_entity.dart';
import 'package:dayflow/features/settings/domain/app_preferences.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException, sqlite3;

import 'test_cleanup.dart';

void main() {
  late AppDatabase db;
  late WriteMetadata metadata;
  late SqliteTaskRepository tasks;
  late SqliteNoteRepository notes;
  late SqliteCategoryRepository categories;
  late SqliteSettingsRepository settings;
  var now = 1800000000000;
  var fixtureClosed = false;
  final date = LocalDate(2026, 11, 18);

  setUp(() {
    fixtureClosed = false;
    now = 1800000000000;
    db = AppDatabase(NativeDatabase.memory());
    metadata = WriteMetadata(now: () => now);
    tasks = SqliteTaskRepository(db, metadata);
    notes = SqliteNoteRepository(db, metadata);
    categories = SqliteCategoryRepository(db, metadata);
    settings = SqliteSettingsRepository(db, metadata);
  });
  tearDown(() async {
    if (!fixtureClosed) await db.close();
  });

  test(
    'Fresh v1 schema opens with safe settings and no fabricated user data',
    () async {
      await db.initialize();
      expect(await tasks.onDate(date), isEmpty);
      expect(await notes.all(), isEmpty);
      expect(await categories.all(), isEmpty);
      final prefs = await settings.read();
      expect(prefs.themeMode, AppThemePreference.light);
      expect(prefs.remindersEnabled, isFalse);
      expect(prefs.companionEnabled, isFalse);
      expect(prefs.onboardingCompleted, isFalse);
      expect(
        (await db.customSelect('PRAGMA foreign_keys').getSingle()).read<int>(
          'foreign_keys',
        ),
        1,
      );
    },
  );

  test('Task CRUD preserves UUID/createdAt, clears nullable values, and excludes deleted rows', () async {
    final reminder = ReminderInstant(
      DateTime.utc(2026, 11, 18, 9),
      timezone: 'Asia/Kolkata',
    );
    final created = await tasks.create(
      TaskInput(
        title: '  Read  ',
        scheduledDate: date,
        description: 'Book',
        priority: TaskPriority.high,
        reminder: reminder,
      ),
    );
    expect(
      created.id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(created.title, 'Read');
    expect(created.createdAt, now);
    expect(created.reminder!.epochMilliseconds, reminder.epochMilliseconds);
    now += 1000;
    final edited = await tasks.update(
      created.id,
      TaskInput(title: 'Read again', scheduledDate: date.addDays(1)),
    );
    expect(edited.id, created.id);
    expect(edited.createdAt, created.createdAt);
    expect(edited.updatedAt, now);
    expect(edited.priority, isNull);
    expect(edited.description, isNull);
    expect(edited.reminder, isNull);
    expect(await tasks.onDate(date), isEmpty);
    expect((await tasks.onDate(date.addDays(1))).single.id, created.id);
    await tasks.softDelete(created.id);
    expect(await tasks.get(created.id), isNull);
    expect(await tasks.onDate(date.addDays(1)), isEmpty);
    expect((await tasks.get(created.id, includeDeleted: true))!.deletedAt, now);
    await tasks.restore(created.id);
    expect((await tasks.get(created.id))!.createdAt, created.createdAt);
    expect((await tasks.get(created.id))!.deletedAt, isNull);
  });

  test('Completion/reopening timestamps are consistent, idempotent, and robust to clock rollback', () async {
    final task = await tasks.create(
      TaskInput(title: 'Done', scheduledDate: date),
    );
    now += 500;
    final completed = await tasks.setCompleted(task.id, true);
    expect(completed.completedAt, now);
    now += 500;
    expect(
      (await tasks.setCompleted(task.id, true)).updatedAt,
      completed.updatedAt,
    );
    now -= 5000;
    final reopened = await tasks.setCompleted(task.id, false);
    expect(reopened.completedAt, isNull);
    expect(reopened.updatedAt, completed.updatedAt);
    expect(reopened.createdAt, task.createdAt);
    await tasks.softDelete(task.id);
    await expectLater(tasks.setCompleted(task.id, true), throwsStateError);
  });

  test('Date query scales beyond 100 rows, orders pending first and skips soft deletions', () async {
    await db.transaction(() async {
      for (var i = 0; i < 110; i++) {
        await tasks.create(TaskInput(title: 'Task $i', scheduledDate: date));
        now++;
      }
    });
    final original = await tasks.onDate(date);
    await tasks.setCompleted(original.first.id, true);
    await tasks.softDelete(original[1].id);
    await tasks.create(
      TaskInput(title: 'Tomorrow', scheduledDate: date.addDays(1)),
    );
    final rows = await tasks.onDate(date);
    expect(rows, hasLength(109));
    expect(rows.first.title, 'Task 2');
    expect(rows.last.id, original.first.id);
    expect(rows.where((t) => t.isCompleted), hasLength(1));
    final plan = await db
        .customSelect(
          "EXPLAIN QUERY PLAN SELECT * FROM tasks WHERE scheduled_date = ? AND deleted_at IS NULL ORDER BY is_completed, created_at, id",
          variables: [Variable.withString(date.toString())],
        )
        .get();
    expect(
      plan.map((r) => r.read<String>('detail')).join(' '),
      contains('tasks_active_date_status'),
    );
  });

  test('Watch queries react to committed writes and deletion', () async {
    final values = <int>[];
    final stream = tasks.watchDate(date);
    final subscription = stream.listen((rows) => values.add(rows.length));
    try {
      await expectLater(stream.first, completion(isEmpty));
      final task = await tasks.create(
        TaskInput(title: 'Reactive', scheduledDate: date),
      );
      await expectLater(stream.first, completion(hasLength(1)));
      await tasks.softDelete(task.id);
      await expectLater(stream.first, completion(isEmpty));
      expect(values, contains(1));
    } finally {
      await subscription.cancel();
    }
  });

  test('Notes are independently undated, editable, pinned, deletable, and restorable', () async {
    final a = await notes.create(
      const NoteInput(content: 'Independent', title: '  Thought  '),
    );
    expect(a.date, isNull);
    expect(a.linkedTaskId, isNull);
    expect(a.title, 'Thought');
    now += 100;
    final b = await notes.create(NoteInput(content: 'Dated', date: date));
    expect((await notes.all()).first.id, b.id);
    await notes.setPinned(a.id, true);
    expect((await notes.all()).first.id, a.id);
    final edited = await notes.update(
      a.id,
      const NoteInput(content: 'Updated', title: ' '),
    );
    expect(edited.createdAt, a.createdAt);
    expect(edited.title, isNull);
    expect(edited.isPinned, isTrue);
    expect((await notes.onDate(date)).single.id, b.id);
    await notes.softDelete(a.id);
    expect(await notes.get(a.id), isNull);
    await notes.restore(a.id);
    expect((await notes.get(a.id))!.content, 'Updated');
  });

  test('Relationships reject missing/deleted assignments and preserve historical links on soft deletion', () async {
    final category = await categories.create(
      const CategoryInput(name: 'Work', color: 0xA98AFF),
    );
    final task = await tasks.create(
      TaskInput(
        title: 'Work task',
        scheduledDate: date,
        categoryId: category.id,
      ),
    );
    final note = await notes.create(
      NoteInput(
        content: 'Context',
        categoryId: category.id,
        linkedTaskId: task.id,
      ),
    );
    await categories.softDelete(category.id);
    await tasks.softDelete(task.id);
    expect((await notes.get(note.id))!.linkedTaskId, task.id);
    await expectLater(
      tasks.create(
        TaskInput(title: 'New', scheduledDate: date, categoryId: category.id),
      ),
      throwsArgumentError,
    );
    await expectLater(
      notes.create(NoteInput(content: 'New', linkedTaskId: task.id)),
      throwsArgumentError,
    );
    await expectLater(
      notes.create(const NoteInput(content: 'New', categoryId: 'missing')),
      throwsArgumentError,
    );
    final edited = await notes.update(
      note.id,
      NoteInput(
        content: 'Still editable',
        categoryId: category.id,
        linkedTaskId: task.id,
      ),
    );
    expect(edited.content, 'Still editable');
    await tasks.restore(task.id);
    await categories.restore(category.id);
    expect((await categories.all()).single.id, category.id);
    await expectLater(
      db.customStatement('DELETE FROM categories WHERE id = ?', [category.id]),
      throwsA(isA<SqliteException>()),
    );
  });

  test('Category CRUD validates colors, active names, and transactional restore conflicts', () async {
    final a = await categories.create(
      const CategoryInput(name: ' Work ', color: 0xA98AFF),
    );
    await expectLater(
      categories.create(const CategoryInput(name: 'work', color: 1)),
      throwsA(isA<SqliteException>()),
    );
    await expectLater(
      categories.create(const CategoryInput(name: ' ', color: 1)),
      throwsArgumentError,
    );
    await expectLater(
      categories.create(const CategoryInput(name: 'Bad color', color: -1)),
      throwsArgumentError,
    );
    now += 100;
    final changed = await categories.update(
      a.id,
      const CategoryInput(name: 'Office', color: 0x7C5CFF),
    );
    expect(changed.createdAt, a.createdAt);
    expect(changed.updatedAt, now);
    await categories.softDelete(a.id);
    await categories.create(const CategoryInput(name: 'Office', color: 0));
    await expectLater(
      categories.restore(a.id),
      throwsA(isA<SqliteException>()),
    );
    expect(
      (await categories.get(a.id, includeDeleted: true))!.deletedAt,
      isNotNull,
    );
    expect(await categories.all(), hasLength(1));
  });

  test('Settings persist validated values and reject invalid opacity including NaN', () async {
    final changed = (await settings.read()).copyWith(
      themeMode: AppThemePreference.dark,
      onboardingCompleted: true,
      companionSide: CompanionSide.left,
      companionSize: 64,
      companionOpacity: 0.75,
    );
    final written = await settings.write(changed);
    expect(written.updatedAt, now);
    final read = await settings.read();
    expect(read.themeMode, AppThemePreference.dark);
    expect(read.onboardingCompleted, isTrue);
    expect(read.companionSize, 64);
    expect(read.companionOpacity, 0.75);
    for (final opacity in [0.0, 2.0, double.nan, double.infinity]) {
      await expectLater(
        settings.write(read.copyWith(companionOpacity: opacity)),
        throwsArgumentError,
      );
    }
    await expectLater(
      settings.write(read.copyWith(companionSize: 1)),
      throwsArgumentError,
    );
    expect((await settings.read()).companionOpacity, 0.75);
  });

  test(
    'SQLite constraints protect native-side writes and foreign keys',
    () async {
      final task = await tasks.create(
        TaskInput(title: 'Valid', scheduledDate: date),
      );
      for (final sql in [
        "UPDATE tasks SET title = ' ' WHERE id = ?",
        "UPDATE tasks SET scheduled_date = '2025-02-29' WHERE id = ?",
        "UPDATE tasks SET scheduled_date = '2026-02-30' WHERE id = ?",
        "UPDATE tasks SET priority = 'urgent' WHERE id = ?",
        'UPDATE tasks SET is_completed = 1 WHERE id = ?',
        "UPDATE tasks SET category_id = 'missing' WHERE id = ?",
        'UPDATE tasks SET updated_at = 0 WHERE id = ?',
        "UPDATE tasks SET reminder_timezone = 'Asia/Kolkata' WHERE id = ?",
      ]) {
        await expectLater(
          db.customStatement(sql, [task.id]),
          throwsA(isA<SqliteException>()),
          reason: sql,
        );
      }
      expect((await tasks.get(task.id))!.title, 'Valid');
      await expectLater(
        tasks.create(TaskInput(title: ' \n ', scheduledDate: date)),
        throwsArgumentError,
      );
    },
  );

  test('A failed multi-entity transaction rolls back all inserts', () async {
    await expectLater(
      db.transaction(() async {
        await categories.create(
          const CategoryInput(name: 'Rollback', color: 1),
        );
        await tasks.create(
          TaskInput(title: 'Rollback task', scheduledDate: date),
        );
        await notes.create(const NoteInput(content: 'Rollback note'));
        throw StateError('Simulated failure');
      }),
      throwsStateError,
    );
    expect(await categories.all(), isEmpty);
    expect(await tasks.onDate(date), isEmpty);
    expect(await notes.all(), isEmpty);
  });

  test('Riverpod repositories share one overridable database', () async {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        writeMetadataProvider.overrideWithValue(metadata),
      ],
    );
    try {
      final task = await container
          .read(taskRepositoryProvider)
          .create(TaskInput(title: 'Provider', scheduledDate: date));
      expect((await db.taskDao.find(task.id))!.title, 'Provider');
      expect(await container.read(noteRepositoryProvider).all(), isEmpty);
      expect(await container.read(categoryRepositoryProvider).all(), isEmpty);
      expect(
        (await container.read(settingsRepositoryProvider).read())
            .companionEnabled,
        isFalse,
      );
    } finally {
      container.dispose();
    }
  });

  test('File-backed data survives close/reopen with schema version and settings intact', () async {
    await db.close();
    fixtureClosed = true;
    final directory = await Directory.systemTemp.createTemp(
      'dayflow-persistence-',
    );
    final file = File('${directory.path}${Platform.pathSeparator}test.sqlite');
    AppDatabase? disk;
    try {
      disk = AppDatabase(NativeDatabase(file));
      final diskTasks = SqliteTaskRepository(disk, metadata);
      final task = await diskTasks.create(
        TaskInput(title: 'Persist me', scheduledDate: date),
      );
      await SqliteSettingsRepository(
        disk,
        metadata,
      ).write(const AppPreferences(themeMode: AppThemePreference.dark));
      await disk.close();
      disk = null;
      disk = AppDatabase(NativeDatabase(file));
      expect(
        (await SqliteTaskRepository(disk, metadata).get(task.id))!.title,
        'Persist me',
      );
      expect(
        (await SqliteSettingsRepository(disk, metadata).read()).themeMode,
        AppThemePreference.dark,
      );
      expect(
        (await disk.customSelect('PRAGMA user_version').getSingle()).read<int>(
          'user_version',
        ),
        1,
      );
      expect(
        (await disk.customSelect('PRAGMA journal_mode').getSingle())
            .read<String>('journal_mode'),
        'delete',
      );
    } finally {
      await disk?.close();
      // Only remove the exact unique temporary directory created above.
      await removeOwnedTestDirectory(directory);
    }
  });

  test(
    'A newer schema is rejected without resetting version or losing data',
    () async {
      await db.close();
      fixtureClosed = true;
      final directory = await Directory.systemTemp.createTemp(
        'dayflow-future-schema-',
      );
      final path = '${directory.path}${Platform.pathSeparator}future.sqlite';
      final raw = sqlite3.open(path);
      raw.execute('CREATE TABLE future_data (value TEXT NOT NULL)');
      raw.execute("INSERT INTO future_data VALUES ('keep me')");
      raw.execute('PRAGMA user_version = 99');
      raw.close();
      final future = AppDatabase(NativeDatabase(File(path)));
      try {
        await expectLater(
          future.initialize(),
          throwsA(isA<UnsupportedError>()),
        );
      } finally {
        await future.close();
      }
      final verify = sqlite3.open(path);
      try {
        expect(verify.select('PRAGMA user_version').single['user_version'], 99);
        expect(
          verify.select('SELECT value FROM future_data').single['value'],
          'keep me',
        );
      } finally {
        verify.close();
        await removeOwnedTestDirectory(directory);
      }
    },
  );
}
