import 'package:dayflow/core/utils/local_date.dart';
import 'package:dayflow/features/tasks/domain/daily_tasks.dart';
import 'package:dayflow/features/tasks/domain/task_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = LocalDate(2026, 11, 18);
  TaskEntity task(
    String id, {
    bool completed = false,
    bool deleted = false,
    LocalDate? date,
  }) => TaskEntity(
    id: id,
    title: id,
    scheduledDate: date ?? today,
    isCompleted: completed,
    createdAt: 1,
    updatedAt: 1,
    completedAt: completed ? 1 : null,
    deletedAt: deleted ? 1 : null,
  );

  test(
    'Progress excludes deleted tasks and other dates, and rounds consistently',
    () {
      final day = DailyTasks(today, [
        task('one', completed: true),
        task('two'),
        task('three'),
        task('deleted', deleted: true, completed: true),
        task('tomorrow', date: today.addDays(1), completed: true),
      ]);
      expect(day.total, 3);
      expect(day.completed.single.id, 'one');
      expect(day.pending.length, 2);
      expect(day.percentage, 33);
      expect(day.fraction, closeTo(1 / 3, .0001));
    },
  );

  test(
    'Zero tasks is zero progress; completing/reopening uses current records',
    () {
      expect(DailyTasks(today, []).fraction, 0);
      expect(DailyTasks(today, [task('one', completed: true)]).percentage, 100);
      expect(DailyTasks(today, [task('one')]).percentage, 0);
    },
  );
}
