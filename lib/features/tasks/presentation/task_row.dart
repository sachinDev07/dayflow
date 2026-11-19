import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/design_tokens.dart';
import '../../settings/domain/category_entity.dart';
import '../domain/task_entity.dart';
import 'date_labels.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.task,
    required this.busy,
    required this.onToggle,
    required this.onEdit,
    this.category,
  });
  final TaskEntity task;
  final bool busy;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final CategoryEntity? category;

  @override
  Widget build(BuildContext context) {
    final colors = DayflowColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: task.isCompleted ? colors.surface : colors.canvas,
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            label: '${task.isCompleted ? 'Reopen' : 'Complete'} ${task.title}',
            checked: task.isCompleted,
            child: IconButton(
              key: ValueKey('toggle-${task.id}'),
              tooltip: task.isCompleted ? 'Reopen task' : 'Complete task',
              onPressed: busy ? null : onToggle,
              icon: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : DayflowMotion.interaction,
                child: Icon(
                  task.isCompleted
                      ? LucideIcons.circleCheck
                      : LucideIcons.circle,
                  key: ValueKey(task.isCompleted),
                  size: 25,
                  color: task.isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : colors.secondaryText,
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              key: ValueKey('edit-${task.id}'),
              onTap: busy ? null : onEdit,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: task.isCompleted
                            ? colors.secondaryText
                            : colors.text,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.priority != null || category != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            if (task.priority != null)
                              Text(
                                '${priorityLabel(task.priority!.name)} priority',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            if (category != null)
                              Text(
                                category!.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Edit task',
            onPressed: busy ? null : onEdit,
            icon: const Icon(LucideIcons.ellipsis, size: 20),
          ),
        ],
      ),
    );
  }
}
