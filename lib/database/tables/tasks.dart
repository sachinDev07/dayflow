import 'package:drift/drift.dart';

import 'categories.dart';
import 'entity_columns.dart';

@DataClassName('TaskRecord')
@TableIndex.sql(
  'CREATE INDEX tasks_active_date_status ON tasks (scheduled_date, is_completed, created_at, id) WHERE deleted_at IS NULL',
)
class Tasks extends Table with EntityColumns {
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get scheduledDate => text()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get priority => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get reminderAt => integer().nullable()();
  TextColumn get reminderTimezone => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK(length(id) = 36)',
    'CHECK(length(trim(title)) > 0)',
    "CHECK(scheduled_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND substr(scheduled_date, 1, 4) != '0000' AND date(scheduled_date, '+0 days') IS NOT NULL AND date(scheduled_date, '+0 days') = scheduled_date)",
    "CHECK(priority IS NULL OR priority IN ('low', 'medium', 'high'))",
    'CHECK((is_completed = 0 AND completed_at IS NULL) OR (is_completed = 1 AND completed_at IS NOT NULL))',
    'CHECK(completed_at IS NULL OR (completed_at >= created_at AND completed_at <= updated_at))',
    'CHECK(reminder_timezone IS NULL OR (reminder_at IS NOT NULL AND length(trim(reminder_timezone)) > 0))',
    'CHECK(created_at >= 0 AND updated_at >= created_at)',
    'CHECK(deleted_at IS NULL OR (deleted_at >= created_at AND deleted_at <= updated_at))',
  ];
}
