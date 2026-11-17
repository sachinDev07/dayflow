import 'package:material_ui/material_ui.dart';

import '../../app/theme/design_tokens.dart';

class DayflowButton extends StatelessWidget {
  const DayflowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = DayflowColors.of(context);
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: enabled ? colors.actionEnd : colors.divider,
        borderRadius: BorderRadius.circular(DayflowRadius.pill),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.actionStart, colors.actionEnd],
                  )
                : null,
          ),
          child: InkWell(
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52, minWidth: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DayflowSpace.xl,
                  vertical: DayflowSpace.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 20,
                        color: enabled ? colors.onAction : colors.secondaryText,
                      ),
                      const SizedBox(width: DayflowSpace.sm),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: enabled
                              ? colors.onAction
                              : colors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
