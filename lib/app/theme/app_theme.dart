import 'package:material_ui/material_ui.dart';

// Minimal M1 shell styling. Full themes, typography, and tokens belong to M2.
ThemeData buildAppTheme() {
  final colors =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFFA98AFF),
        brightness: Brightness.light,
      ).copyWith(
        primary: const Color(0xFF7C5CFF),
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: const Color(0xFF171526),
        onSurfaceVariant: const Color(0xFF625F75),
        outlineVariant: const Color(0xFFEAE5F3),
      );
  final base = ThemeData(
    colorScheme: colors,
    scaffoldBackgroundColor: Colors.white,
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.6),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
        height: 1.5,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: const Color(0xFFEDE5FF),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? colors.onSurface : colors.onSurfaceVariant,
        );
      }),
    ),
  );
}
