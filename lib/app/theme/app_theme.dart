import 'package:material_ui/material_ui.dart';

import 'design_tokens.dart';

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;
  final colors = dark ? DayflowColors.dark : DayflowColors.light;
  final primary = dark ? colors.lavender : colors.actionEnd;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: colors.purple,
        brightness: brightness,
      ).copyWith(
        primary: primary,
        onPrimary: dark ? colors.canvas : colors.onAction,
        primaryContainer: colors.accentSurface,
        onPrimaryContainer: colors.text,
        surface: colors.canvas,
        onSurface: colors.text,
        onSurfaceVariant: colors.secondaryText,
        outlineVariant: colors.divider,
        error: colors.danger,
      );
  final base = ThemeData(
    colorScheme: scheme,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: colors.canvas,
    extensions: [colors],
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(DayflowRadius.input),
    borderSide: BorderSide(color: colors.divider),
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.8,
        color: colors.text,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.6,
        color: colors.text,
      ),
      titleLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.5,
        color: colors.text,
      ),
      titleMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: colors.text,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        height: 1.5,
        color: colors.text,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        height: 1.5,
        color: colors.secondaryText,
      ),
      labelLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: colors.text,
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.all(DayflowSpace.lg),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: BorderSide(color: colors.danger),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: BorderSide(color: colors.danger, width: 1.5),
      ),
      labelStyle: TextStyle(color: colors.secondaryText),
      hintStyle: TextStyle(color: colors.secondaryText),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.canvas,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DayflowRadius.sheet),
        ),
      ),
      dragHandleColor: colors.secondaryText,
      dragHandleSize: const Size(40, 4),
    ),
    dividerTheme: DividerThemeData(
      color: colors.divider,
      thickness: 1,
      space: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: colors.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 23,
          color: states.contains(WidgetState.selected)
              ? primary
              : colors.secondaryText,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? primary
              : colors.secondaryText,
        ),
      ),
    ),
  );
}
