import 'package:drift/drift.dart';

@DataClassName('SettingsRecord')
class AppSettings extends Table {
  IntColumn get id => integer()();
  TextColumn get themeMode => text().withDefault(const Constant('light'))();
  BoolColumn get remindersEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get companionEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get companionSide => text().withDefault(const Constant('right'))();
  IntColumn get companionSize => integer().withDefault(const Constant(56))();
  RealColumn get companionOpacity => real().withDefault(const Constant(1.0))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK(id = 1)',
    "CHECK(theme_mode IN ('light', 'dark', 'system'))",
    "CHECK(companion_side IN ('left', 'right'))",
    'CHECK(companion_size BETWEEN 40 AND 96)',
    'CHECK(companion_opacity BETWEEN 0.3 AND 1.0)',
    'CHECK(updated_at >= 0)',
  ];
}
