import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme/design_tokens.dart';
import '../../../core/utils/local_date.dart';
import '../../tasks/presentation/date_labels.dart';

class HomeDateSelector extends StatefulWidget {
  const HomeDateSelector({
    super.key,
    required this.selected,
    required this.today,
    required this.onSelected,
  });
  final LocalDate selected;
  final LocalDate today;
  final ValueChanged<LocalDate> onSelected;

  @override
  State<HomeDateSelector> createState() => _HomeDateSelectorState();
}

class _HomeDateSelectorState extends State<HomeDateSelector> {
  final _scroll = ScrollController();
  LocalDate get selected => widget.selected;
  LocalDate get today => widget.today;
  ValueChanged<LocalDate> get onSelected => widget.onSelected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _revealSelected();
  }

  @override
  void didUpdateWidget(HomeDateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != selected) _revealSelected();
  }

  void _revealSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final width = 48 + 14 * (scale - 1).clamp(0, 3);
      final index =
          DateTime.utc(selected.year, selected.month, selected.day).weekday - 1;
      final offset =
          index * (width + 6) +
          width / 2 -
          _scroll.position.viewportDimension / 2;
      _scroll.jumpTo(offset.clamp(0, _scroll.position.maxScrollExtent));
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DayflowColors.of(context);
    final weekday = DateTime.utc(
      selected.year,
      selected.month,
      selected.day,
    ).weekday;
    // Keep boundary years within the supported calendar range.
    final start = DateTime.utc(
      selected.year,
      selected.month,
      selected.day - weekday + 1,
    );
    final days = List.generate(7, (index) => start.add(Duration(days: index)))
        .where((date) => date.year >= 1 && date.year <= 9999)
        .map(LocalDate.fromDateTime)
        .toList();
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                key: const ValueKey('home-date-picker'),
                onPressed: () async {
                  final date = await pickTaskDate(context, selected);
                  if (date != null) onSelected(date);
                },
                iconAlignment: IconAlignment.end,
                icon: const Icon(LucideIcons.chevronDown, size: 18),
                label: Text(dateLabel(context, selected)),
              ),
            ),
            TextButton(
              onPressed: () => onSelected(today),
              child: const Text('Today'),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              tooltip: 'Previous week',
              onPressed: selected.compareTo(LocalDate(1, 1, 8)) < 0
                  ? null
                  : () => onSelected(selected.addDays(-7)),
              icon: const Icon(LucideIcons.chevronLeft, size: 18),
            ),
            Expanded(
              child: SizedBox(
                height: 72 * scale.clamp(1, 4),
                child: ListView.separated(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final chosen = day == selected;
                    return Semantics(
                      selected: chosen,
                      label:
                          '${dateLabel(context, day)}${day == today ? ', today' : ''}',
                      button: true,
                      child: Material(
                        color: chosen ? colors.actionEnd : colors.surface,
                        borderRadius: BorderRadius.circular(
                          DayflowRadius.input,
                        ),
                        child: InkWell(
                          key: ValueKey('day-$day'),
                          borderRadius: BorderRadius.circular(
                            DayflowRadius.input,
                          ),
                          onTap: () => onSelected(day),
                          child: SizedBox(
                            width: 48 + 14 * (scale - 1).clamp(0, 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  MaterialLocalizations.of(context)
                                      .narrowWeekdays[DateTime.utc(
                                        day.year,
                                        day.month,
                                        day.day,
                                      ).weekday %
                                      7],
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: chosen
                                            ? colors.onAction
                                            : colors.secondaryText,
                                      ),
                                ),
                                Text(
                                  '${day.day}',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: chosen
                                            ? colors.onAction
                                            : colors.text,
                                      ),
                                ),
                                if (day == today)
                                  Icon(
                                    LucideIcons.circle,
                                    size: 5,
                                    color: chosen
                                        ? colors.onAction
                                        : colors.actionEnd,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next week',
              onPressed: selected.compareTo(LocalDate(9999, 12, 24)) > 0
                  ? null
                  : () => onSelected(selected.addDays(7)),
              icon: const Icon(LucideIcons.chevronRight, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}
