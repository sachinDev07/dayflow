import 'package:dayflow/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

void main() {
  test('Fresh schema matches the committed version-1 snapshot', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final verifier = SchemaVerifier(GeneratedHelper());
    try {
      await verifier.migrateAndValidate(database, 1);
      expect((await database.settingsDao.read()).themeMode, 'light');
    } finally {
      await database.close();
    }
  });

  test(
    'An existing version-1 schema opens without recreation or data loss',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final database = AppDatabase(await verifier.startAt(1));
      try {
        await database.initialize();
        await database.customStatement(
          'INSERT INTO categories (id, name, color, created_at, updated_at) VALUES (?, ?, ?, ?, ?)',
          ['00000000-0000-4000-8000-000000000001', 'Preserved', 1, 1000, 1000],
        );
        await verifier.migrateAndValidate(database, 1);
        expect((await database.categoryDao.all()).single.name, 'Preserved');
      } finally {
        await database.close();
      }
    },
  );
}
