import '../../../core/utils/local_date.dart';
import 'task_entity.dart';

abstract interface class TaskRepository {
  Future<TaskEntity> create(TaskInput input);
  Future<TaskEntity?> get(String id, {bool includeDeleted = false});
  Future<List<TaskEntity>> onDate(LocalDate date);
  Stream<List<TaskEntity>> watchDate(LocalDate date);
  Future<TaskEntity> update(String id, TaskInput input);
  Future<TaskEntity> setCompleted(String id, bool completed);
  Future<void> softDelete(String id);
  Future<void> restore(String id);
}
