import 'package:drift/drift.dart';

import 'entity_columns.dart';

@DataClassName('CategoryRecord')
@TableIndex.sql(
  'CREATE UNIQUE INDEX categories_active_name ON categories (name COLLATE NOCASE) WHERE deleted_at IS NULL',
)
class Categories extends Table with EntityColumns {
  TextColumn get name => text()();
  IntColumn get color => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK(length(id) = 36)',
    'CHECK(length(trim(name)) > 0)',
    'CHECK(color BETWEEN 0 AND 16777215)',
    'CHECK(created_at >= 0 AND updated_at >= created_at)',
    'CHECK(deleted_at IS NULL OR (deleted_at >= created_at AND deleted_at <= updated_at))',
  ];
}
