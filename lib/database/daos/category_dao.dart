part of '../app_database.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);
  Future<CategoryRecord?> find(String id, {bool includeDeleted = false}) =>
      (select(categories)..where(
            (c) =>
                c.id.equals(id) &
                (includeDeleted ? const Constant(true) : c.deletedAt.isNull()),
          ))
          .getSingleOrNull();
  SimpleSelectStatement<$CategoriesTable, CategoryRecord> _active() =>
      select(categories)
        ..where((c) => c.deletedAt.isNull())
        ..orderBy([
          (c) => OrderingTerm(expression: c.name.lower()),
          (c) => OrderingTerm(expression: c.id),
        ]);
  Future<List<CategoryRecord>> all() => _active().get();
  Stream<List<CategoryRecord>> watchAll() => _active().watch();
  Future<void> add(CategoriesCompanion values) async =>
      into(categories).insert(values);
  Future<int> change(String id, CategoriesCompanion values) =>
      (update(categories)..where((c) => c.id.equals(id))).write(values);
}
