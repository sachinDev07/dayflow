import 'package:drift/drift.dart';

import 'categories.dart';
import 'entity_columns.dart';
import 'tasks.dart';

@DataClassName('NoteRecord')
@TableIndex.sql(
  'CREATE INDEX notes_active_recent ON notes (is_pinned DESC, updated_at DESC, id) WHERE deleted_at IS NULL',
)
@TableIndex.sql(
  'CREATE INDEX notes_active_date ON notes (note_date) WHERE deleted_at IS NULL',
)
class Notes extends Table with EntityColumns {
  TextColumn get title => text().nullable()();
  TextColumn get content => text()();
  TextColumn get noteDate => text().nullable()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get linkedTaskId => text().nullable().references(Tasks, #id)();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK(length(id) = 36)',
    "CHECK(note_date IS NULL OR (note_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND substr(note_date, 1, 4) != '0000' AND date(note_date, '+0 days') IS NOT NULL AND date(note_date, '+0 days') = note_date))",
    'CHECK(created_at >= 0 AND updated_at >= created_at)',
    'CHECK(deleted_at IS NULL OR (deleted_at >= created_at AND deleted_at <= updated_at))',
  ];
}
