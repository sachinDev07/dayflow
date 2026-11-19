# M4: core task management

Completed 18 November 2026 (Asia/Calcutta), on the M3 implementation in `af80e6c`. The approved product brief and design assets remain unchanged.

## Scope and design

Home now consumes saved tasks. Its hierarchy follows `design-preferences/01_dayflow_home_dashboard_design.png`: existing exact logo/header, compact greeting, date selection, modest progress summary, pending task rows, collapsible completed tasks, Quick Add, and the existing five destinations. `02_dayflow_add_edit_task_flow_v4.png` takes precedence for the compact Add/Edit sheet. Poster backgrounds, fabricated avatars, sample tasks, and example statistics are not application data.

The progress display uses a slim animated bar to keep tasks prominent. Shared M2 typography, lavender surfaces, darker accessible purple actions, spacing, and light/dark themes are retained. Completion uses a brief check transition. Reduced motion skips these transitions.

Implemented flows:

- Select a day in the horizontal week strip, move by week, choose an arbitrary date, or return to Today.
- Read pending tasks for that date and expand completed tasks to edit or reopen them.
- Quick Add opens the shared sheet with immediate title focus. Today/Tomorrow/Pick Date remain visible before expanding optional fields.
- Save a required nonblank title and scheduled date, with optional priority, existing category, and description. Editing uses the same form with saved values, including nullable-value clearing.
- Complete or reopen tasks; progress is derived from active records for the selected date, including safe zero-task and all-complete states.
- Delete from the editor after confirmation, with an eight-second Undo action. Undo restores the same row and ID; normal reads/progress exclude deleted tasks.
- Handle loading, read errors with Retry, failed mutations, and failed saves without losing the form draft. Pending writes disable duplicate submission and form editing.
- Close or use Android Back without silently losing a dirty form. A confirmation offers Keep editing or Discard. Barrier tap and swipe dismissal are disabled for this editor, while the shared M2 preview sheet retains its previous behavior.

## Architecture and assumptions

The existing schema, migrations, DAOs, and repository interfaces are unchanged. No dependencies or native permissions are added. Widgets call repositories provided by Riverpod; they do not execute SQL or call Android APIs.

`tasksOnDateProvider` provides an automatically disposed stream per calendar date; `activeCategoriesProvider` supplies active categories. Home partitions actual rows through the pure `DailyTasks` domain calculation. Neither progress counters nor duplicate task copies are persisted. Pending and completed lists use lazy slivers with stable task keys, so 100+ tasks do not require building every row at once.

The shared `showTaskEditor(initialDate: ..., task: ...)` API is ready for Calendar in M5. Home passes its selected date, avoiding adding to a different day from the one being viewed. Today remains the default on launch. Picking Today follows the current day; an explicitly selected different date stays selected across midnight or resume. A local clock refreshes each minute and on foreground resume. An open draft retains its chosen scheduled date rather than moving silently at midnight.

Successful mutations update the list through Drift's watch queries. No optimistic status is kept that could falsely show a failed write as complete. Completion/deletion timestamps and ID preservation remain repository responsibilities. Home owns a local ScaffoldMessenger/Scaffold for snackbar and floating-action geometry within the existing shell, so Undo does not cover Quick Add.

Important boundaries:

- Reminder scheduling, permission flows, and reminder selection belong to M7. M4 does not offer a time control that could imply notifications work. Editing preserves an existing reminder instant and timezone; it does not create or schedule one.
- Category management belongs to M7. M4 can select or clear existing active categories, preserves historical associations on unchanged edits, and permits saving with no category. No fictional default categories are inserted.
- Calendar remains M5, Notes UI M6, settings/reminders M7, insights M8, and the native companion M9. Existing destination placeholders remain until their milestones.
- Tasks remain on their chosen dates; none are automatically carried forward.
- Appearance settings remain M7. Both themes render, but the product still defaults to light.

## Verification

The workflow tests exercise the actual SQLite repositories using isolated in-memory databases. A small wrapper injects read/write failures and a delayed save to verify error recovery and prevent duplicate submissions. Shell/design tests override task streams to remain independent of Android plugins.

Checks cover task creation, title trimming/blank rejection, completion and reopening, progress, optional fields and preserved metadata/reminders, deletion and undo, Today/Tomorrow/custom dates, selected-date propagation, unsaved drafts, read retries, failed writes, duplicate-save protection, lazy rendering and scrolling with 110 tasks, foreground date refresh, dark theme, and a 320x568 viewport with 200% text and keyboard insets. Existing database/schema/design/navigation tests remain part of the full suite.

During development, large-text date-strip overflow and snackbar overlap with Quick Add were found and corrected. The date strip scales vertically with text size and keeps its selected day visible. Failed writes reveal error feedback at the top of the scrollable form, while the action stays fixed above the keyboard; this also prevents error text from squeezing the layout at 200% text size.

```powershell
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter build apk --debug
flutter run -d <android-device-id>
```

- Formatting: 68 Dart files, no changes required.
- `flutter analyze`: no issues found.
- `flutter test --concurrency=1`: all **38 tests passed**, including 10 new M4 domain/workflow tests and the 28 existing checks. Serial test execution reduced host memory pressure.
- The final `flutter build apk --debug` succeeded. APK metadata retains the DAYFLOW label, `com.dayflow.dayflow`, minimum API 24, and target API 36. The final APK is `build/app/outputs/flutter-apk/app-debug.apk` (ignored local build output).
- Android 16/API 36 x86_64 emulator: Quick Add autofocus and keyboard-safe action visually reviewed; a real task was created, completed to 100%, expanded in Completed, reopened to pending, edited with High priority, and verified after force-stop/relaunch. Delete confirmation removed it from active progress; Undo restored the edited task and priority. The verification fixture was then soft-deleted through the UI, leaving no active sample tasks.
- Checked runtime logs contained no DAYFLOW crash, Flutter exception, or layout overflow. Screenshots include `build/m4-home-empty.png`, `build/m4-quick-add.png`, `build/m4-home-task.png`, `build/m4-completed-expanded.png`, `build/m4-edit-task.png`, `build/m4-after-relaunch.png`, `build/m4-undo-restored.png`, and `build/m4-home-final.png`. These files are ignored local artifacts.
- The approved brief's SHA-256 remains `3680B011EC078B0836FD7A55FCAD480938C689B197D2B0A3A1EC5642A122E5EC`. Schema, generated database code, dependency lockfile, and Android configuration have no M4 changes.

The device check used the existing DAYFLOW API 36 AVD with 2 cores, 2 GB RAM, software rendering, and a 720x1600 display override at density 280. Gradle was stopped before launching it. This host showed memory pressure, a slow Android cold boot, a System UI timeout, and intermittent UI automation interruptions. An installation attempted during startup failed; retrying after boot with a non-streamed install succeeded. The final app was verified after these interruptions, and the emulator was stopped afterward.

These debug/emulator checks do not establish production performance, physical-device coverage, older Android behavior, or Kotlin concurrency safety.

M5 is next: monthly Calendar navigation, task/note indicators, selected-day tasks, and the shared task form receiving the selected calendar date.
