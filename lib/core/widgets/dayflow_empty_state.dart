import 'package:material_ui/material_ui.dart';

import '../../app/theme/design_tokens.dart';

class DayflowEmptyState extends StatelessWidget {
  const DayflowEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.action,
  });
  final String title;
  final String description;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = DayflowColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.accentSurface,
            borderRadius: BorderRadius.circular(DayflowRadius.card),
          ),
          child: Icon(icon, size: 28, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: DayflowSpace.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: DayflowSpace.sm),
        Text(
          description,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        if (action != null) ...[
          const SizedBox(height: DayflowSpace.xl),
          action!,
        ],
      ],
    );
  }
}
