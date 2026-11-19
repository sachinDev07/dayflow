import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme/design_tokens.dart';
import '../../../core/utils/local_date.dart';
import '../../../core/widgets/dayflow_button.dart';
import '../../../core/widgets/dayflow_text_field.dart';
import '../../../database/database_providers.dart';
import '../../settings/domain/category_entity.dart';
import '../application/task_providers.dart';
import '../domain/task_entity.dart';
import 'date_labels.dart';
import 'task_date_choices.dart';

final class TaskEditorResult {
  const TaskEditorResult(this.task, {this.deleted = false});
  final TaskEntity task;
  final bool deleted;
}

/// Shared by Home and, in M5, Calendar. Only explicit close/Back can discard.
Future<TaskEditorResult?> showTaskEditor(
  BuildContext context, {
  required LocalDate initialDate,
  TaskEntity? task,
}) => showModalBottomSheet<TaskEditorResult>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  isDismissible: false,
  enableDrag: false,
  showDragHandle: false,
  sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
      ? AnimationStyle.noAnimation
      : const AnimationStyle(
          duration: DayflowMotion.interaction,
          reverseDuration: DayflowMotion.interaction,
        ),
  builder: (context) => TaskEditor(initialDate: initialDate, task: task),
);

class TaskEditor extends ConsumerStatefulWidget {
  const TaskEditor({super.key, required this.initialDate, this.task});
  final LocalDate initialDate;
  final TaskEntity? task;

  @override
  ConsumerState<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends ConsumerState<TaskEditor> {
  final _form = GlobalKey<FormState>();
  final _contentScroll = ScrollController();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late LocalDate _date;
  TaskPriority? _priority;
  String? _categoryId;
  late bool _expanded;
  bool _busy = false;
  bool _confirming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title ?? '')
      ..addListener(_changed);
    _description = TextEditingController(text: task?.description ?? '')
      ..addListener(_changed);
    _date = task?.scheduledDate ?? widget.initialDate;
    _priority = task?.priority;
    _categoryId = task?.categoryId;
    _expanded = task != null;
  }

  void _changed() => setState(() {});

  bool get _dirty =>
      _title.text != (widget.task?.title ?? '') ||
      _description.text != (widget.task?.description ?? '') ||
      _date != (widget.task?.scheduledDate ?? widget.initialDate) ||
      _priority != widget.task?.priority ||
      _categoryId != widget.task?.categoryId;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _contentScroll.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _busy = false;
      _error = message;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _contentScroll.hasClients) _contentScroll.jumpTo(0);
    });
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String action,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep editing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _close() async {
    if (_busy || _confirming) return;
    _confirming = true;
    final discard =
        !_dirty ||
        await _confirm(
          title: 'Discard changes?',
          body: 'Your unsaved changes will be lost.',
          action: 'Discard',
        );
    _confirming = false;
    if (mounted && discard) Navigator.pop(context);
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repository = ref.read(taskRepositoryProvider);
      final input = TaskInput(
        title: _title.text,
        scheduledDate: _date,
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        priority: _priority,
        categoryId: _categoryId,
        reminder: widget.task?.reminder,
      );
      final task = widget.task == null
          ? await repository.create(input)
          : await repository.update(widget.task!.id, input);
      if (mounted) Navigator.pop(context, TaskEditorResult(task));
    } catch (_) {
      if (mounted) {
        _showError('Couldn’t save this task. Try again.');
      }
    }
  }

  Future<void> _delete() async {
    if (_busy || _confirming) return;
    _confirming = true;
    final confirmed = await _confirm(
      title: 'Delete task?',
      body: 'You can undo this after deleting.',
      action: 'Delete task',
    );
    _confirming = false;
    if (!mounted || !confirmed) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(taskRepositoryProvider).softDelete(widget.task!.id);
      if (mounted) {
        Navigator.pop(context, TaskEditorResult(widget.task!, deleted: true));
      }
    } catch (_) {
      if (mounted) {
        _showError('Couldn’t delete this task. Try again.');
      }
    }
  }

  Future<void> _choosePriority() => showDialog<void>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: const Text('Priority'),
      children: [
        for (final priority in <TaskPriority?>[null, ...TaskPriority.values])
          SimpleDialogOption(
            onPressed: () {
              setState(() => _priority = priority);
              Navigator.pop(dialogContext);
            },
            child: Text(
              priority == null ? 'None' : priorityLabel(priority.name),
            ),
          ),
      ],
    ),
  );

  Future<void> _chooseCategory(List<CategoryEntity> categories) =>
      showDialog<void>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('Category'),
          children: [
            if (categories.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No categories available. Tasks can be saved without one.',
                ),
              ),
            SimpleDialogOption(
              onPressed: () {
                setState(() => _categoryId = null);
                Navigator.pop(dialogContext);
              },
              child: const Text('None'),
            ),
            for (final category in categories)
              SimpleDialogOption(
                onPressed: () {
                  setState(() => _categoryId = category.id);
                  Navigator.pop(dialogContext);
                },
                child: Text(category.name),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colors = DayflowColors.of(context);
    final today = LocalDate.fromDateTime(ref.watch(currentTimeProvider));
    final categories = ref.watch(activeCategoriesProvider);
    final available = categories.asData?.value ?? <CategoryEntity>[];
    final categoryName = available
        .where((c) => c.id == _categoryId)
        .firstOrNull
        ?.name;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close();
      },
      child: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * .94,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Close task editor',
                          onPressed: _busy ? null : _close,
                          icon: const Icon(LucideIcons.x),
                        ),
                        Expanded(
                          child: Text(
                            widget.task == null ? 'Add Task' : 'Edit Task',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (widget.task != null)
                          IconButton(
                            tooltip: 'Delete task',
                            onPressed: _busy ? null : _delete,
                            icon: Icon(
                              LucideIcons.trash2,
                              color: colors.danger,
                            ),
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      controller: _contentScroll,
                      padding: const EdgeInsets.symmetric(
                        horizontal: DayflowSpace.page,
                      ),
                      child: Form(
                        key: _form,
                        child: AbsorbPointer(
                          absorbing: _busy,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_error != null)
                                Semantics(
                                  liveRegion: true,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      _error!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: colors.danger),
                                    ),
                                  ),
                                ),
                              DayflowTextField(
                                label: 'Task title',
                                hint: 'What do you need to do?',
                                controller: _title,
                                enabled: !_busy,
                                autofocus: widget.task == null,
                                textInputAction: TextInputAction.done,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'Enter a task title'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TaskDateChoices(
                                selected: _date,
                                today: today,
                                enabled: !_busy,
                                onSelected: (date) =>
                                    setState(() => _date = date),
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  _expanded ? 'Fewer options' : 'More options',
                                ),
                                trailing: Icon(
                                  _expanded
                                      ? LucideIcons.chevronUp
                                      : LucideIcons.chevronDown,
                                ),
                                onTap: () =>
                                    setState(() => _expanded = !_expanded),
                              ),
                              if (_expanded) ...[
                                _option(
                                  LucideIcons.flag,
                                  'Priority',
                                  _priority == null
                                      ? 'None'
                                      : priorityLabel(_priority!.name),
                                  _choosePriority,
                                ),
                                const Divider(),
                                if (categories.hasError)
                                  ListTile(
                                    title: const Text(
                                      'Couldn’t load categories',
                                    ),
                                    trailing: TextButton(
                                      onPressed: () => ref.invalidate(
                                        activeCategoriesProvider,
                                      ),
                                      child: const Text('Retry'),
                                    ),
                                  )
                                else
                                  _option(
                                    LucideIcons.tag,
                                    'Category',
                                    _categoryId == null
                                        ? 'None'
                                        : categoryName ?? 'Archived category',
                                    categories.isLoading
                                        ? null
                                        : () => _chooseCategory(available),
                                  ),
                                const Divider(),
                                const SizedBox(height: 16),
                                DayflowTextField(
                                  label: 'Description (optional)',
                                  hint: 'Add details…',
                                  controller: _description,
                                  enabled: !_busy,
                                  maxLines: 3,
                                ),
                                if (widget.task?.reminder != null)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Text(
                                      'Your existing reminder is retained when you edit this task.',
                                    ),
                                  ),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: DayflowButton(
                        key: const ValueKey('save-task'),
                        label: _busy
                            ? 'Saving…'
                            : widget.task == null
                            ? 'Save Task'
                            : 'Update Task',
                        icon: LucideIcons.check,
                        onPressed: _busy || _title.text.trim().isEmpty
                            ? null
                            : _save,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _option(
    IconData icon,
    String title,
    String value,
    VoidCallback? action,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, size: 22),
    title: Text(title),
    subtitle: Text(value),
    trailing: const Icon(LucideIcons.chevronRight, size: 20),
    onTap: action,
  );
}
