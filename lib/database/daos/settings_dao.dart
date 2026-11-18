part of '../app_database.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);
  Future<SettingsRecord> read() =>
      (select(appSettings)..where((s) => s.id.equals(1))).getSingle();
  Stream<SettingsRecord> watch() =>
      (select(appSettings)..where((s) => s.id.equals(1))).watchSingle();
  Future<void> write(AppSettingsCompanion values) async =>
      (update(appSettings)..where((s) => s.id.equals(1))).write(values);
}
