import 'package:material_ui/material_ui.dart';

enum AppDestination {
  home('/home', 'Home', Icons.home_outlined, Icons.home_rounded),
  calendar(
    '/calendar',
    'Calendar',
    Icons.calendar_month_outlined,
    Icons.calendar_month_rounded,
  ),
  notes('/notes', 'Notes', Icons.notes_outlined, Icons.notes_rounded),
  insights(
    '/insights',
    'Insights',
    Icons.bar_chart_outlined,
    Icons.bar_chart_rounded,
  ),
  settings(
    '/settings',
    'Settings',
    Icons.settings_outlined,
    Icons.settings_rounded,
  );

  const AppDestination(this.path, this.label, this.icon, this.selectedIcon);

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  static AppDestination fromPath(String path) {
    return values.firstWhere(
      (destination) => path == destination.path,
      orElse: () => home,
    );
  }
}
