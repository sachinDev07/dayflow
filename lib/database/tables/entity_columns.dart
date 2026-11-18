import 'package:drift/drift.dart';

mixin EntityColumns on Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
}
