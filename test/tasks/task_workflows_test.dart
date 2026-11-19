import 'dart:async';

import 'package:dayflow/app/app.dart';
import 'package:dayflow/core/utils/local_date.dart';
import 'package:dayflow/core/utils/reminder_instant.dart';
import 'package:dayflow/database/app_database.dart';
import 'package:dayflow/database/database_providers.dart';
import 'package:dayflow/database/write_metadata.dart';
import 'package:dayflow/features/settings/data/sqlite_category_repository.dart';
import 'package:dayflow/features/settings/domain/category_entity.dart';
import 'package:dayflow/features/tasks/application/task_providers.dart';
import 'package:dayflow/features/tasks/data/sqlite_task_repository.dart';
import 'package:dayflow/features/tasks/domain/task_entity.dart';
import 'package:dayflow/features/tasks/domain/task_repository.dart';
import 'package:dayflow/features/tasks/presentation/task_editor.dart';
import 'package:dayflow/features/tasks/presentation/task_row.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Inject failures/delays while keeping successful operations on real SQLite.
class ControlledTasks implements TaskRepository {
  ControlledTasks(this.delegate);
  final TaskRepository delegate;
  bool failRead = false;
  bool failSave = false;
  bool failMutation = false;
  Completer<void>? saveGate;
  int creates = 0;

  @override
  Future<TaskEntity> create(TaskInput input) async {
    creates++;
    await saveGate?.future;
    if (failSave) throw StateError('Injected failure');
    return delegate.create(input);
  }

  @override
  Future<TaskEntity> update(String id, TaskInput input) {
    if (failSave) throw StateError('Injected failure');
    return delegate.update(id, input);
  }

  @override
  Stream<List<TaskEntity>> watchDate(LocalDate date) => failRead
      ? Stream.error(StateError('Injected failure'))
      : delegate.watchDate(date);
  @override
  Future<List<TaskEntity>> onDate(LocalDate date) => delegate.onDate(date);
  @override
  Future<TaskEntity?> get(String id, {bool includeDeleted = false}) =>
      delegate.get(id, includeDeleted: includeDeleted);
  @override
  Future<TaskEntity> setCompleted(String id, bool completed) {
    if (failMutation) throw StateError('Injected failure');
    return delegate.setCompleted(id, completed);
  }

  @override
  Future<void> softDelete(String id) => delegate.softDelete(id);
  @override
  Future<void> restore(String id) => delegate.restore(id);
}

void main() {
  final today = LocalDate(2026, 11, 18);
  late AppDatabase db;
  late ControlledTasks tasks;
  late ProviderContainer container;
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 11, 18, 10);
    db = AppDatabase(NativeDatabase.memory());
    tasks = ControlledTasks(SqliteTaskRepository(db, WriteMetadata()));
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        taskRepositoryProvider.overrideWithValue(tasks),
        currentTimeProvider.overrideWith((ref) => now),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> launch(
    WidgetTester tester, {
    ThemeMode theme = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: DayflowApp(themeMode: theme),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await Scrollable.ensureVisible(
      tester.element(finder),
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, Finder finder, String value) async {
    await tester.enterText(finder, value);
    await tester.pump();
  }

  testWidgets(
    'Quick Add persists, completion updates progress, reopening restores pending',
    (tester) async {
      await launch(tester);
      expect(find.text('No tasks for today'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('quick-add')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .focusNode
            .hasFocus,
        isTrue,
      );
      await type(
        tester,
        find.byType(TextFormField).first,
        '   Plan a calm day   ',
      );
      await tester.tap(find.text('Save Task'));
      await tester.pumpAndSettle();
      final task = (await tasks.onDate(today)).single;
      expect(task.title, 'Plan a calm day');
      expect(find.text('0 of 1 tasks completed · 0%'), findsOneWidget);
      await tapVisible(tester, find.byKey(ValueKey('toggle-${task.id}')));
      expect(find.text('1 of 1 tasks completed · 100%'), findsOneWidget);
      expect((await tasks.get(task.id))!.completedAt, isNotNull);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('completed-section')),
        150,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tapVisible(tester, find.byKey(const ValueKey('completed-section')));
      await tapVisible(tester, find.byKey(ValueKey('toggle-${task.id}')));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 700));
      await tester.pumpAndSettle();
      expect(find.text('0 of 1 tasks completed · 0%'), findsOneWidget);
      expect((await tasks.get(task.id))!.completedAt, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Edit optional details/date preserves identity and reminder; delete undo restores progress',
    (tester) async {
      final category = await SqliteCategoryRepository(
        db,
        WriteMetadata(),
      ).create(const CategoryInput(name: 'Work', color: 0xA98AFF));
      final task = await tasks.create(
        TaskInput(
          title: 'Original title',
          scheduledDate: today,
          reminder: ReminderInstant(DateTime.utc(2026, 11, 19, 9)),
        ),
      );
      await launch(tester);
      await tapVisible(tester, find.byKey(ValueKey('edit-${task.id}')));
      await type(tester, find.byType(TextFormField).first, 'Updated title');
      await tapVisible(tester, find.text('Priority'));
      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Category'));
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(TextFormField).last);
      await type(tester, find.byType(TextFormField).last, 'Helpful details');
      await tester.tap(find.text('Update Task'));
      await tester.pumpAndSettle();
      final updated = (await tasks.get(task.id))!;
      expect(updated.description, 'Helpful details');
      expect(updated.priority, TaskPriority.high);
      expect(updated.categoryId, category.id);
      expect(
        updated.reminder!.epochMilliseconds,
        task.reminder!.epochMilliseconds,
      );
      expect(updated.createdAt, task.createdAt);
      await tapVisible(tester, find.byKey(ValueKey('edit-${task.id}')));
      await tester.tap(find.byTooltip('Delete task'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete task').last);
      await tester.pumpAndSettle();
      expect(await tasks.get(task.id), isNull);
      expect(find.text('0 of 0 tasks completed · 0%'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect((await tasks.get(task.id))!.id, task.id);
      expect(find.text('0 of 1 tasks completed · 0%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Today/Tomorrow and arbitrary selected date reach the same shared form',
    (tester) async {
      await launch(tester);
      await tester.tap(find.byKey(const ValueKey('quick-add')));
      await tester.pumpAndSettle();
      await type(tester, find.byType(TextFormField).first, 'Tomorrow task');
      await tapVisible(
        tester,
        find.byKey(const ValueKey('task-date-Tomorrow')),
      );
      await tester.tap(find.text('Save Task'));
      await tester.pumpAndSettle();
      expect(await tasks.onDate(today), isEmpty);
      final task = (await tasks.onDate(today.addDays(1))).single;
      expect(find.text('Tomorrow task'), findsNothing);
      await tapVisible(tester, find.byKey(ValueKey('day-${today.addDays(1)}')));
      expect(find.text('Tomorrow task'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('quick-add')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TaskEditor>(find.byType(TaskEditor)).initialDate,
        today.addDays(1),
      );
      await tester.tap(find.byTooltip('Close task editor'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(ValueKey('edit-${task.id}')));
      await tapVisible(
        tester,
        find.byKey(const ValueKey('task-date-Pick Date')),
      );
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect((await tasks.get(task.id))!.scheduledDate, today.addDays(1));
      await tapVisible(
        tester,
        find.byKey(const ValueKey('task-date-Pick Date')),
      );
      await tester.tap(find.byTooltip('Switch to input'));
      await tester.pumpAndSettle();
      await type(
        tester,
        find.descendant(
          of: find.byType(DatePickerDialog),
          matching: find.byType(TextFormField),
        ),
        '12/31/2026',
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update Task'));
      await tester.pumpAndSettle();
      expect(
        (await tasks.get(task.id))!.scheduledDate,
        LocalDate(2026, 12, 31),
      );
      expect(await tasks.onDate(today.addDays(1)), isEmpty);
    },
  );

  testWidgets(
    'Unsaved changes survive Back and barrier tap until explicitly discarded',
    (tester) async {
      await launch(tester);
      await tester.tap(find.byKey(const ValueKey('quick-add')));
      await tester.pumpAndSettle();
      await type(tester, find.byType(TextFormField).first, 'Do not lose this');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(TaskEditor), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('Do not lose this'), findsOneWidget);
      await tester.tap(find.byTooltip('Close task editor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(TaskEditor), findsNothing);
      expect(await tasks.onDate(today), isEmpty);
    },
  );

  testWidgets(
    'Read errors retry, failed saves keep draft, busy saves cannot duplicate',
    (tester) async {
      tasks.failRead = true;
      await launch(tester);
      expect(find.text('Couldn’t load your tasks'), findsOneWidget);
      tasks.failRead = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('No tasks for today'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('quick-add')));
      await tester.pumpAndSettle();
      await type(tester, find.byType(TextFormField).first, '   ');
      await tester.tap(find.text('Save Task'));
      await tester.pumpAndSettle();
      expect(tasks.creates, 0);
      await type(tester, find.byType(TextFormField).first, 'Keep this draft');
      tasks.failSave = true;
      await tester.tap(find.text('Save Task'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Couldn’t save this task'), findsOneWidget);
      expect(find.text('Keep this draft'), findsOneWidget);
      tasks.failSave = false;
      tasks.saveGate = Completer<void>();
      await tester.tap(find.text('Save Task'));
      await tester.pump();
      await tester.tap(find.text('Saving…'));
      await tester.pump();
      expect(tasks.creates, 2);
      tasks.saveGate!.complete();
      await tester.pumpAndSettle();
      expect((await tasks.onDate(today)).length, 1);
    },
  );

  testWidgets(
    '100+ tasks render lazily; failed completion leaves saved progress intact',
    (tester) async {
      for (var i = 0; i < 110; i++) {
        await tasks.create(TaskInput(title: 'Task $i', scheduledDate: today));
      }
      await launch(tester);
      expect(find.byType(TaskRow).evaluate().length, lessThan(30));
      final first = (await tasks.onDate(today)).first;
      tasks.failMutation = true;
      await tapVisible(tester, find.byKey(ValueKey('toggle-${first.id}')));
      expect(find.textContaining('Couldn’t update this task'), findsOneWidget);
      expect((await tasks.get(first.id))!.isCompleted, isFalse);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 700));
      await tester.pumpAndSettle();
      expect(find.text('0 of 110 tasks completed · 0%'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Task 109'),
        500,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
        maxScrolls: 40,
      );
      expect(find.text('Task 109'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Dark theme, small screen and 200% text keep Save and errors above the keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.view.resetViewInsets);
      await launch(tester, theme: ThemeMode.dark);
      await tester.tap(find.byKey(const ValueKey('quick-add')));
      await tester.pumpAndSettle();
      await type(tester, find.byType(TextFormField).first, 'A readable task');
      final save = find.text('Save Task');
      expect(tester.getBottomRight(save).dy, lessThan(348));
      tasks.failSave = true;
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.textContaining('Couldn’t save this task'), findsOneWidget);
      expect(tester.takeException(), isNull);
      tasks.failSave = false;
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect((await tasks.onDate(today)).single.title, 'A readable task');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Following Today refreshes on resume; explicit selected dates remain selected',
    (tester) async {
      await launch(tester);
      now = DateTime(2026, 11, 19, 8);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quick-add')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TaskEditor>(find.byType(TaskEditor)).initialDate,
        today.addDays(1),
      );
      await tester.tap(find.byTooltip('Close task editor'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(ValueKey('day-$today')));
      now = DateTime(2026, 11, 20, 8);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quick-add')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TaskEditor>(find.byType(TaskEditor)).initialDate,
        today,
      );
    },
  );
}
