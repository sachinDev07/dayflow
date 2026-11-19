import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/utils/local_date.dart';
import '../../../core/widgets/dayflow_button.dart';
import '../../../core/widgets/dayflow_empty_state.dart';
import '../../../core/widgets/dayflow_surface.dart';
import '../../../database/database_providers.dart';
import '../../tasks/application/task_providers.dart';
import '../../tasks/domain/daily_tasks.dart';
import '../../tasks/domain/task_entity.dart';
import '../../tasks/presentation/task_editor.dart';
import '../../tasks/presentation/task_row.dart';
import '../../../app/theme/design_tokens.dart';
import 'daily_progress.dart';
import 'home_date_selector.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  // Null follows the current day across midnight and foreground resumes.
  LocalDate? _selected;
  bool _showCompleted = false;
  final Set<String> _busy = {};
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.invalidate(currentTimeProvider);
  }

  Future<void> _edit(LocalDate date, [TaskEntity? task]) async {
    final repository = ref.read(taskRepositoryProvider);
    final messenger = _messengerKey.currentState!;
    final result = await showTaskEditor(context, initialDate: date, task: task);
    if (result == null || !mounted) return;
    if (result.deleted) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Task deleted'),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await repository.restore(result.task.id);
              } catch (_) {
                if (mounted) {
                  _message(
                    'Couldn’t restore this task. Please try again.',
                    retry: () => _restore(result.task.id),
                  );
                }
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _restore(String id) async {
    try {
      await ref.read(taskRepositoryProvider).restore(id);
    } catch (_) {
      if (mounted) {
        _message(
          'Couldn’t restore this task. Please try again.',
          retry: () => _restore(id),
        );
      }
    }
  }

  void _message(String text, {VoidCallback? retry}) {
    final messenger = _messengerKey.currentState!;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        action: retry == null
            ? null
            : SnackBarAction(label: 'Retry', onPressed: retry),
      ),
    );
  }

  Future<void> _toggle(TaskEntity task) async {
    if (_busy.contains(task.id)) return;
    setState(() => _busy.add(task.id));
    try {
      await ref
          .read(taskRepositoryProvider)
          .setCompleted(task.id, !task.isCompleted);
    } catch (_) {
      if (mounted) _message('Couldn’t update this task. Please try again.');
    } finally {
      if (mounted) setState(() => _busy.remove(task.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(currentTimeProvider);
    final today = LocalDate.fromDateTime(now);
    final date = _selected ?? today;
    final tasks = ref.watch(tasksOnDateProvider(date));
    final categories = ref.watch(activeCategoriesProvider).asData?.value ?? [];
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    final colors = DayflowColors.of(context);

    Widget row(TaskEntity task) => TaskRow(
      key: ValueKey(task.id),
      task: task,
      busy: _busy.contains(task.id),
      category: categories.where((c) => c.id == task.categoryId).firstOrNull,
      onToggle: () => _toggle(task),
      onEdit: () => _edit(date, task),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ScaffoldMessenger(
          key: _messengerKey,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: CustomScrollView(
              key: const PageStorageKey('home-scroll'),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        const Text('Your day. Your pace. Your progress.'),
                        const SizedBox(height: 20),
                        HomeDateSelector(
                          selected: date,
                          today: today,
                          onSelected: (value) {
                            setState(() {
                              _selected = value == today ? null : value;
                              _showCompleted = false;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                ...tasks.when(
                  loading: () => [
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: CircularProgressIndicator(
                            semanticsLabel: 'Loading tasks',
                          ),
                        ),
                      ),
                    ),
                  ],
                  error: (error, stack) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: DayflowEmptyState(
                          title: 'Couldn’t load your tasks',
                          description: 'Please try again. Your saved tasks have not been removed.',
                          icon: LucideIcons.cloudOff,
                          action: DayflowButton(
                            label: 'Retry',
                            onPressed: () =>
                                ref.invalidate(tasksOnDateProvider(date)),
                          ),
                        ),
                      ),
                    ),
                  ],
                  data: (records) {
                    final day = DailyTasks(date, records);
                    return <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverToBoxAdapter(
                          child: DailyProgress(
                            tasks: day,
                            isToday: date == today,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${date == today ? 'Today’s' : 'Daily'} tasks (${day.pending.length})',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Add task',
                                onPressed: () => _edit(date),
                                icon: Icon(
                                  LucideIcons.plus,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (day.total == 0)
                        SliverPadding(
                          padding: const EdgeInsets.all(20),
                          sliver: SliverToBoxAdapter(
                            child: DayflowSurface(
                              child: DayflowEmptyState(
                                title: date == today
                                    ? 'No tasks for today'
                                    : 'No tasks for this day',
                                description:
                                    'A clean slate. Add a task to get started.',
                                icon: LucideIcons.clipboardList,
                                action: DayflowButton(
                                  label: 'Add Task',
                                  icon: LucideIcons.plus,
                                  onPressed: () => _edit(date),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (day.total > 0 && day.pending.isEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'All tasks complete. Make room for a little breathing space.',
                            ),
                          ),
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverList.builder(
                          itemCount: day.pending.length,
                          itemBuilder: (context, index) =>
                              row(day.pending[index]),
                        ),
                      ),
                      if (day.completed.isNotEmpty) ...[
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverToBoxAdapter(
                            child: Semantics(
                              expanded: _showCompleted,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                key: const ValueKey('completed-section'),
                                title: Text(
                                  'Completed (${day.completed.length})',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                trailing: Icon(
                                  _showCompleted
                                      ? LucideIcons.chevronUp
                                      : LucideIcons.chevronDown,
                                ),
                                onTap: () => setState(
                                  () => _showCompleted = !_showCompleted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_showCompleted)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            sliver: SliverList.builder(
                              itemCount: day.completed.length,
                              itemBuilder: (context, index) =>
                                  row(day.completed[index]),
                            ),
                          ),
                      ],
                    ];
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              key: const ValueKey('quick-add'),
              tooltip: 'Quick Add',
              backgroundColor: colors.actionEnd,
              foregroundColor: colors.onAction,
              onPressed: () => _edit(date),
              child: const Icon(LucideIcons.plus),
            ),
          ),
        ),
      ),
    );
  }
}
