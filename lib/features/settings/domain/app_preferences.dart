enum AppThemePreference { light, dark, system }

enum CompanionSide { left, right }

final class AppPreferences {
  const AppPreferences({
    this.themeMode = AppThemePreference.light,
    this.remindersEnabled = false,
    this.companionEnabled = false,
    this.onboardingCompleted = false,
    this.companionSide = CompanionSide.right,
    this.companionSize = 56,
    this.companionOpacity = 1.0,
    this.updatedAt = 0,
  });
  final AppThemePreference themeMode;
  final bool remindersEnabled;
  final bool companionEnabled;
  final bool onboardingCompleted;
  final CompanionSide companionSide;
  final int companionSize;
  final double companionOpacity;
  final int updatedAt;

  void validate() {
    if (companionSize < 40 || companionSize > 96) {
      throw ArgumentError.value(companionSize, 'companionSize');
    }
    if (!companionOpacity.isFinite ||
        companionOpacity < 0.3 ||
        companionOpacity > 1) {
      throw ArgumentError.value(companionOpacity, 'companionOpacity');
    }
  }

  AppPreferences copyWith({
    AppThemePreference? themeMode,
    bool? remindersEnabled,
    bool? companionEnabled,
    bool? onboardingCompleted,
    CompanionSide? companionSide,
    int? companionSize,
    double? companionOpacity,
  }) => AppPreferences(
    themeMode: themeMode ?? this.themeMode,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    companionEnabled: companionEnabled ?? this.companionEnabled,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    companionSide: companionSide ?? this.companionSide,
    companionSize: companionSize ?? this.companionSize,
    companionOpacity: companionOpacity ?? this.companionOpacity,
    updatedAt: updatedAt,
  );
}
