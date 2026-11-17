import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum AppDestination {
  home('/home', 'Home', LucideIcons.house, LucideIcons.house),
  calendar(
    '/calendar',
    'Calendar',
    LucideIcons.calendarDays,
    LucideIcons.calendarDays,
  ),
  notes('/notes', 'Notes', LucideIcons.notebookPen, LucideIcons.notebookPen),
  insights(
    '/insights',
    'Insights',
    LucideIcons.chartNoAxesColumnIncreasing,
    LucideIcons.chartNoAxesColumnIncreasing,
  ),
  settings('/settings', 'Settings', LucideIcons.settings, LucideIcons.settings);

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
