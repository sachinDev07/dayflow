import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../../../database/write_metadata.dart';
import '../domain/app_preferences.dart';
import '../domain/settings_repository.dart';

final class SqliteSettingsRepository implements SettingsRepository {
  SqliteSettingsRepository(this._db, this._metadata);
  final AppDatabase _db;
  final WriteMetadata _metadata;
  @override
  Future<AppPreferences> read() async => _map(await _db.settingsDao.read());
  @override
  Stream<AppPreferences> watch() => _db.settingsDao.watch().map(_map);
  @override
  Future<AppPreferences> write(AppPreferences preferences) =>
      _db.transaction(() async {
        preferences.validate();
        final previous = await _db.settingsDao.read();
        await _db.settingsDao.write(
          AppSettingsCompanion(
            themeMode: Value(preferences.themeMode.name),
            remindersEnabled: Value(preferences.remindersEnabled),
            companionEnabled: Value(preferences.companionEnabled),
            onboardingCompleted: Value(preferences.onboardingCompleted),
            companionSide: Value(preferences.companionSide.name),
            companionSize: Value(preferences.companionSize),
            companionOpacity: Value(preferences.companionOpacity),
            updatedAt: Value(_metadata.timestamp(after: previous.updatedAt)),
          ),
        );
        return _map(await _db.settingsDao.read());
      });
  AppPreferences _map(SettingsRecord row) => AppPreferences(
    themeMode: AppThemePreference.values.byName(row.themeMode),
    remindersEnabled: row.remindersEnabled,
    companionEnabled: row.companionEnabled,
    onboardingCompleted: row.onboardingCompleted,
    companionSide: CompanionSide.values.byName(row.companionSide),
    companionSize: row.companionSize,
    companionOpacity: row.companionOpacity,
    updatedAt: row.updatedAt,
  );
}
