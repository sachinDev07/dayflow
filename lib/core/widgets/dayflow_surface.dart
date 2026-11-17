import 'package:material_ui/material_ui.dart';

import '../../app/theme/design_tokens.dart';

class DayflowSurface extends StatelessWidget {
  const DayflowSurface({
    super.key,
    required this.child,
    this.accent = false,
    this.padding = const EdgeInsets.all(DayflowSpace.xl),
  });
  final Widget child;
  final bool accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = DayflowColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent ? colors.accentSurface : colors.surface,
        borderRadius: BorderRadius.circular(DayflowRadius.card),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
