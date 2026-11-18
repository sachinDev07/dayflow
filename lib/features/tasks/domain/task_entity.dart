import '../../../core/utils/local_date.dart';
import '../../../core/utils/reminder_instant.dart';

enum TaskPriority { low, medium, high }

final class TaskInput {
  const TaskInput({
    required this.title,
    required this.scheduledDate,
    this.description,
    this.categoryId,
    this.priority,
    this.reminder,
  });
  final String title;
  final LocalDate scheduledDate;
  final String? description;
  final String? categoryId;
  final TaskPriority? priority;
  final ReminderInstant? reminder;

  void validate() {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'Required');
    }
  }
}

final class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.scheduledDate,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.categoryId,
    this.priority,
    this.completedAt,
    this.reminder,
    this.deletedAt,
  });
  final String id;
  final String title;
  final LocalDate scheduledDate;
  final String? description;
  final String? categoryId;
  final TaskPriority? priority;
  final bool isCompleted;
  final int? completedAt;
  final ReminderInstant? reminder;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
}
