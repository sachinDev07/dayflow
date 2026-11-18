part of '../app_database.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Future<TaskRecord?> find(String id, {bool includeDeleted = false}) =>
      (select(tasks)..where(
            (t) =>
                t.id.equals(id) &
                (includeDeleted ? const Constant(true) : t.deletedAt.isNull()),
          ))
          .getSingleOrNull();

  SimpleSelectStatement<$TasksTable, TaskRecord> _onDate(String date) =>
      select(tasks)
        ..where((t) => t.scheduledDate.equals(date) & t.deletedAt.isNull())
        ..orderBy([
          (t) => OrderingTerm(expression: t.isCompleted),
          (t) => OrderingTerm(expression: t.createdAt),
          (t) => OrderingTerm(expression: t.id),
        ]);

  Future<List<TaskRecord>> onDate(String date) => _onDate(date).get();
  Stream<List<TaskRecord>> watchDate(String date) => _onDate(date).watch();
  Future<void> add(TasksCompanion values) async => into(tasks).insert(values);
  Future<int> change(String id, TasksCompanion values) =>
      (update(tasks)..where((t) => t.id.equals(id))).write(values);
}
