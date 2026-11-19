import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/design_tokens.dart';
import '../../../core/utils/local_date.dart';
import 'date_labels.dart';

class TaskDateChoices extends StatelessWidget {
  const TaskDateChoices({
    super.key,
    required this.selected,
    required this.today,
    required this.onSelected,
    this.enabled = true,
  });
  final LocalDate selected;
  final LocalDate today;
  final ValueChanged<LocalDate> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tomorrow = today.addDays(1);
    final custom = selected != today && selected != tomorrow;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQuery.textScalerOf(context).scale(14) > 21
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / 3;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _choice(
              context,
              width,
              'Today',
              dateLabel(context, today),
              selected == today,
              () => onSelected(today),
            ),
            _choice(
              context,
              width,
              'Tomorrow',
              dateLabel(context, tomorrow),
              selected == tomorrow,
              () => onSelected(tomorrow),
            ),
            _choice(
              context,
              width,
              'Pick Date',
              custom ? dateLabel(context, selected) : null,
              custom,
              () async {
                final date = await pickTaskDate(context, selected);
                if (date != null && context.mounted) onSelected(date);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _choice(
    BuildContext context,
    double width,
    String label,
    String? detail,
    bool selected,
    VoidCallback onTap,
  ) {
    final colors = DayflowColors.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: SizedBox(
        width: width,
        child: OutlinedButton(
          key: ValueKey('task-date-$label'),
          style: OutlinedButton.styleFrom(
            backgroundColor: selected ? colors.accentSurface : colors.surface,
            side: BorderSide(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : colors.divider,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: enabled ? onTap : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label == 'Pick Date')
                const Icon(LucideIcons.calendarDays, size: 20),
              Text(label, textAlign: TextAlign.center),
              if (detail != null)
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
