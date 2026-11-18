import 'app_preferences.dart';

abstract interface class SettingsRepository {
  Future<AppPreferences> read();
  Stream<AppPreferences> watch();
  Future<AppPreferences> write(AppPreferences preferences);
}
