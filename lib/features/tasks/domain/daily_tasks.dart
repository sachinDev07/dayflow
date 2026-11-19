import '../../../core/utils/local_date.dart';
import 'task_entity.dart';

/// A selected day's progress is always derived from its active task records.
final class DailyTasks {
  DailyTasks(LocalDate date, Iterable<TaskEntity> tasks) {
    for (final task in tasks) {
      if (task.deletedAt == null && task.scheduledDate == date) {
        (task.isCompleted ? completed : pending).add(task);
      }
    }
  }

  final List<TaskEntity> pending = [];
  final List<TaskEntity> completed = [];
  int get total => pending.length + completed.length;
  double get fraction => total == 0 ? 0 : completed.length / total;
  int get percentage => (fraction * 100).round();
}
