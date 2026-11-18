import 'app_database.dart';

Future<void> requireActiveCategory(AppDatabase db, String? id) async {
  if (id != null && await db.categoryDao.find(id) == null) {
    throw ArgumentError.value(
      id,
      'categoryId',
      'Category is missing or deleted',
    );
  }
}

Future<void> requireActiveTask(AppDatabase db, String? id) async {
  if (id != null && await db.taskDao.find(id) == null) {
    throw ArgumentError.value(id, 'linkedTaskId', 'Task is missing or deleted');
  }
}
