import 'package:drift/drift.dart';

import '../../../core/utils/local_date.dart';
import '../../../core/utils/reminder_instant.dart';
import '../../../database/app_database.dart';
import '../../../database/repository_guards.dart';
import '../../../database/write_metadata.dart';
import '../domain/task_entity.dart';
import '../domain/task_repository.dart';

final class SqliteTaskRepository implements TaskRepository {
  SqliteTaskRepository(this._db, this._metadata);
  final AppDatabase _db;
  final WriteMetadata _metadata;

  @override
  Future<TaskEntity> create(TaskInput input) => _db.transaction(() async {
    input.validate();
    await requireActiveCategory(_db, input.categoryId);
    final id = _metadata.newId();
    final now = _metadata.timestamp();
    await _db.taskDao.add(
      TasksCompanion.insert(
        id: id,
        title: input.title.trim(),
        scheduledDate: input.scheduledDate.toString(),
        createdAt: now,
        updatedAt: now,
        description: Value(input.description),
        categoryId: Value(input.categoryId),
        priority: Value(input.priority?.name),
        reminderAt: Value(input.reminder?.epochMilliseconds),
        reminderTimezone: Value(input.reminder?.timezone),
      ),
    );
    return _map((await _db.taskDao.find(id))!);
  });

  @override
  Future<TaskEntity?> get(String id, {bool includeDeleted = false}) async {
    final row = await _db.taskDao.find(id, includeDeleted: includeDeleted);
    return row == null ? null : _map(row);
  }

  @override
  Future<List<TaskEntity>> onDate(LocalDate date) async =>
      (await _db.taskDao.onDate(date.toString()))
          .map(_map)
          .toList(growable: false);
  @override
  Stream<List<TaskEntity>> watchDate(LocalDate date) => _db.taskDao
      .watchDate(date.toString())
      .map((rows) => rows.map(_map).toList(growable: false));

  @override
  Future<TaskEntity> update(String id, TaskInput input) =>
      _db.transaction(() async {
        input.validate();
        final row = await _required(id);
        // Existing historical links survive category deletion; new assignments must be active.
        if (input.categoryId != row.categoryId) {
          await requireActiveCategory(_db, input.categoryId);
        }
        await _db.taskDao.change(
          id,
          TasksCompanion(
            title: Value(input.title.trim()),
            scheduledDate: Value(input.scheduledDate.toString()),
            description: Value(input.description),
            categoryId: Value(input.categoryId),
            priority: Value(input.priority?.name),
            reminderAt: Value(input.reminder?.epochMilliseconds),
            reminderTimezone: Value(input.reminder?.timezone),
            updatedAt: Value(_metadata.timestamp(after: row.updatedAt)),
          ),
        );
        return _map((await _db.taskDao.find(id))!);
      });

  @override
  Future<TaskEntity> setCompleted(String id, bool completed) =>
      _db.transaction(() async {
        final row = await _required(id);
        if (row.isCompleted == completed) return _map(row);
        final now = _metadata.timestamp(after: row.updatedAt);
        await _db.taskDao.change(
          id,
          TasksCompanion(
            isCompleted: Value(completed),
            completedAt: Value(completed ? now : null),
            updatedAt: Value(now),
          ),
        );
        return _map((await _db.taskDao.find(id))!);
      });

  @override
  Future<void> softDelete(String id) => _setDeleted(id, true);
  @override
  Future<void> restore(String id) => _setDeleted(id, false);

  Future<void> _setDeleted(String id, bool deleted) =>
      _db.transaction(() async {
        final row = await _required(id, includeDeleted: true);
        if ((row.deletedAt != null) == deleted) return;
        final now = _metadata.timestamp(after: row.updatedAt);
        await _db.taskDao.change(
          id,
          TasksCompanion(
            deletedAt: Value(deleted ? now : null),
            updatedAt: Value(now),
          ),
        );
      });

  Future<TaskRecord> _required(
    String id, {
    bool includeDeleted = false,
  }) async =>
      await _db.taskDao.find(id, includeDeleted: includeDeleted) ??
      (throw StateError('Task is missing or deleted: $id'));

  TaskEntity _map(TaskRecord row) => TaskEntity(
    id: row.id,
    title: row.title,
    scheduledDate: LocalDate.parse(row.scheduledDate),
    description: row.description,
    categoryId: row.categoryId,
    priority: row.priority == null
        ? null
        : TaskPriority.values.byName(row.priority!),
    isCompleted: row.isCompleted,
    completedAt: row.completedAt,
    reminder: row.reminderAt == null
        ? null
        : ReminderInstant(
            DateTime.fromMillisecondsSinceEpoch(row.reminderAt!, isUtc: true),
            timezone: row.reminderTimezone,
          ),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
  );
}
