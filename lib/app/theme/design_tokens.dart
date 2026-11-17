import 'package:material_ui/material_ui.dart';

abstract final class DayflowSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double page = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double section = 40;
}

abstract final class DayflowRadius {
  static const double input = 12;
  static const double card = 16;
  static const double sheet = 24;
  static const double pill = 100;
}

abstract final class DayflowMotion {
  static const interaction = Duration(milliseconds: 200);
  static const entrance = Duration(milliseconds: 220);
}

@immutable
class DayflowColors extends ThemeExtension<DayflowColors> {
  const DayflowColors({
    required this.canvas,
    required this.surface,
    required this.lavender,
    required this.purple,
    required this.text,
    required this.secondaryText,
    required this.divider,
    required this.accentSurface,
    required this.actionStart,
    required this.actionEnd,
    required this.onAction,
    required this.success,
    required this.danger,
  });

  static const light = DayflowColors(
    canvas: Color(0xFFFFFFFF),
    surface: Color(0xFFF8F6FC),
    lavender: Color(0xFFA98AFF),
    purple: Color(0xFF7C5CFF),
    text: Color(0xFF171526),
    secondaryText: Color(0xFF666276),
    divider: Color(0xFFEAE5F3),
    accentSurface: Color(0xFFF0E9FF),
    actionStart: Color(0xFF7950D4),
    actionEnd: Color(0xFF6535CD),
    onAction: Color(0xFFFFFFFF),
    success: Color(0xFF44DE80),
    danger: Color(0xFFC83850),
  );

  static const dark = DayflowColors(
    canvas: Color(0xFF0B0B14),
    surface: Color(0xFF141424),
    lavender: Color(0xFFA98AFF),
    purple: Color(0xFF7C5CFF),
    text: Color(0xFFF5F5FF),
    secondaryText: Color(0xFFAAA6BF),
    divider: Color(0xFF2A2840),
    accentSurface: Color(0xFF29213E),
    actionStart: Color(0xFF7950D4),
    actionEnd: Color(0xFF6535CD),
    onAction: Color(0xFFFFFFFF),
    success: Color(0xFF44DE80),
    danger: Color(0xFFFF8D9A),
  );

  final Color canvas;
  final Color surface;
  final Color lavender;
  final Color purple;
  final Color text;
  final Color secondaryText;
  final Color divider;
  final Color accentSurface;
  final Color actionStart;
  final Color actionEnd;
  final Color onAction;
  final Color success;
  final Color danger;

  static DayflowColors of(BuildContext context) =>
      Theme.of(context).extension<DayflowColors>()!;

  @override
  DayflowColors copyWith({
    Color? canvas,
    Color? surface,
    Color? lavender,
    Color? purple,
    Color? text,
    Color? secondaryText,
    Color? divider,
    Color? accentSurface,
    Color? actionStart,
    Color? actionEnd,
    Color? onAction,
    Color? success,
    Color? danger,
  }) => DayflowColors(
    canvas: canvas ?? this.canvas,
    surface: surface ?? this.surface,
    lavender: lavender ?? this.lavender,
    purple: purple ?? this.purple,
    text: text ?? this.text,
    secondaryText: secondaryText ?? this.secondaryText,
    divider: divider ?? this.divider,
    accentSurface: accentSurface ?? this.accentSurface,
    actionStart: actionStart ?? this.actionStart,
    actionEnd: actionEnd ?? this.actionEnd,
    onAction: onAction ?? this.onAction,
    success: success ?? this.success,
    danger: danger ?? this.danger,
  );

  @override
  DayflowColors lerp(covariant DayflowColors? other, double t) {
    if (other == null) return this;
    return DayflowColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      text: Color.lerp(text, other.text, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accentSurface: Color.lerp(accentSurface, other.accentSurface, t)!,
      actionStart: Color.lerp(actionStart, other.actionStart, t)!,
      actionEnd: Color.lerp(actionEnd, other.actionEnd, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
