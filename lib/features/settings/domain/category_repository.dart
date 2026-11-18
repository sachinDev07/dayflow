import 'category_entity.dart';

abstract interface class CategoryRepository {
  Future<CategoryEntity> create(CategoryInput input);
  Future<CategoryEntity?> get(String id, {bool includeDeleted = false});
  Future<List<CategoryEntity>> all();
  Stream<List<CategoryEntity>> watchAll();
  Future<CategoryEntity> update(String id, CategoryInput input);
  Future<void> softDelete(String id);
  Future<void> restore(String id);
}
