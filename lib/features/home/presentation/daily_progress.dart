import 'package:material_ui/material_ui.dart';

import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/dayflow_surface.dart';
import '../../tasks/domain/daily_tasks.dart';

class DailyProgress extends StatelessWidget {
  const DailyProgress({super.key, required this.tasks, required this.isToday});
  final DailyTasks tasks;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colors = DayflowColors.of(context);
    return Semantics(
      label:
          '${tasks.percentage}% complete, ${tasks.completed.length} of ${tasks.total} tasks completed',
      child: DayflowSurface(
        accent: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isToday ? "Today’s progress" : 'Daily progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '${tasks.completed.length} of ${tasks.total} tasks completed · ${tasks.percentage}%',
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(end: tasks.fraction),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : DayflowMotion.interaction,
              builder: (context, value, child) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: colors.divider,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
