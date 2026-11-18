import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../../../database/write_metadata.dart';
import '../domain/category_entity.dart';
import '../domain/category_repository.dart';

final class SqliteCategoryRepository implements CategoryRepository {
  SqliteCategoryRepository(this._db, this._metadata);
  final AppDatabase _db;
  final WriteMetadata _metadata;
  @override
  Future<CategoryEntity> create(CategoryInput input) =>
      _db.transaction(() async {
        input.validate();
        final id = _metadata.newId();
        final now = _metadata.timestamp();
        await _db.categoryDao.add(
          CategoriesCompanion.insert(
            id: id,
            name: input.name.trim(),
            color: input.color,
            createdAt: now,
            updatedAt: now,
          ),
        );
        return _map((await _db.categoryDao.find(id))!);
      });
  @override
  Future<CategoryEntity?> get(String id, {bool includeDeleted = false}) async {
    final row = await _db.categoryDao.find(id, includeDeleted: includeDeleted);
    return row == null ? null : _map(row);
  }

  @override
  Future<List<CategoryEntity>> all() async =>
      (await _db.categoryDao.all()).map(_map).toList(growable: false);
  @override
  Stream<List<CategoryEntity>> watchAll() => _db.categoryDao.watchAll().map(
    (rows) => rows.map(_map).toList(growable: false),
  );
  @override
  Future<CategoryEntity> update(String id, CategoryInput input) =>
      _db.transaction(() async {
        input.validate();
        final row = await _required(id);
        await _db.categoryDao.change(
          id,
          CategoriesCompanion(
            name: Value(input.name.trim()),
            color: Value(input.color),
            updatedAt: Value(_metadata.timestamp(after: row.updatedAt)),
          ),
        );
        return _map((await _db.categoryDao.find(id))!);
      });
  @override
  Future<void> softDelete(String id) => _setDeleted(id, true);
  @override
  Future<void> restore(String id) => _setDeleted(id, false);
  Future<void> _setDeleted(String id, bool deleted) =>
      _db.transaction(() async {
        final row = await _required(id, includeDeleted: true);
        if ((row.deletedAt != null) == deleted) return;
        final now = _metadata.timestamp(after: row.updatedAt);
        await _db.categoryDao.change(
          id,
          CategoriesCompanion(
            deletedAt: Value(deleted ? now : null),
            updatedAt: Value(now),
          ),
        );
      });
  Future<CategoryRecord> _required(
    String id, {
    bool includeDeleted = false,
  }) async =>
      await _db.categoryDao.find(id, includeDeleted: includeDeleted) ??
      (throw StateError('Category is missing or deleted: $id'));
  CategoryEntity _map(CategoryRecord row) => CategoryEntity(
    id: row.id,
    name: row.name,
    color: row.color,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
  );
}
