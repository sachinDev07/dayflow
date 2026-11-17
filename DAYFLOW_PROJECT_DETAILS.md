# DAYFLOW --- Complete Project Brief for Codex

**Document:** `DAYFLOW_PROJECT_DETAILS.md`\
**Version:** 1.0\
**Status:** Product direction and core UX approved; engineering
implementation to begin\
**Primary platform:** Android\
**Technology:** Flutter + Dart + Kotlin\
**Product type:** Offline-first personal productivity and daily task
companion

------------------------------------------------------------------------

## 1. Instructions to the AI Developer (Codex)

You are acting as a senior Flutter engineer, Android/Kotlin engineer,
product-minded software architect, and UI/UX implementation specialist.

Build DAYFLOW as a real, maintainable, production-quality Android
application---not merely a collection of static screens.

Before implementing a feature:

1.  Read this entire document.
2.  Inspect the existing repository and preserve any valid existing
    work.
3.  Identify the current milestone and implement only the appropriate
    scope.
4.  Follow the approved visual direction and product principles.
5.  Make sensible engineering decisions where details are not specified,
    but document important assumptions.
6.  Do not invent features or add complexity without a clear user
    benefit.
7.  Keep the application buildable after each milestone.
8.  Run formatting, static analysis, tests and an Android build after
    meaningful changes.
9.  Do not claim a feature is complete unless it is implemented and
    tested.
10. If a design asset or exact logo image is not present in the
    repository, do not fabricate an exact replacement. Create a clearly
    documented placeholder and ask for/provide an integration point for
    the approved asset.

**Important:** This brief records the product decisions and discussions
made so far. Some implementation details---such as final Android
SDK/Gradle versions, package versions, exact reminder scheduling
strategy and overlay lifecycle---must be verified against current
toolchain documentation and the actual project. Do not blindly copy
outdated version numbers.

------------------------------------------------------------------------

# 2. Product Overview

## 2.1 Product name

**DAYFLOW**

Working tagline:

> Your day. Your pace. Your progress.

Product category: Personal productivity / task management / daily notes.

## 2.2 Product vision

DAYFLOW is a lightweight personal productivity companion that helps
users capture tasks quickly, organize them by date, keep useful notes,
understand their progress and access their daily tasks through an
optional Android floating companion.

It should feel like a calm, elegant personal assistant---not a corporate
project-management tool.

The product should make it easy to:

-   Capture something that needs to be done.
-   Decide when it should be done: today, tomorrow or another date.
-   See what matters on the current day.
-   Keep notes connected to a date or task when useful.
-   Complete tasks and see meaningful progress.
-   Access a small view of today's tasks without repeatedly opening the
    app.

## 2.3 Problem being solved

People often distribute personal responsibilities across notebooks,
messaging apps, screenshots, reminders and memory. Many task
applications introduce unnecessary complexity through projects, boards,
folders, labels, workflows and extensive configuration.

DAYFLOW should provide a simpler alternative:

-   Fast task entry.
-   Clear date-based organization.
-   Simple daily notes.
-   Calm progress feedback.
-   Optional always-accessible floating companion.
-   Offline-first reliability.

## 2.4 Product philosophy

**Capture quickly. Focus clearly. Complete peacefully.**

Core principles:

1.  Simplicity over unnecessary features.
2.  Tasks and typography are the primary focus.
3.  Fast task creation with minimal friction.
4.  Offline-first functionality.
5.  Attractive, consistent and accessible UI.
6.  User-controlled reminders and floating behavior.
7.  Encourage users without guilt, pressure or manipulative engagement.
8.  Privacy and minimum necessary permissions.
9.  Keep the interface useful rather than decorative.
10. The app should help users spend less time managing tasks, not more
    time inside the app.

------------------------------------------------------------------------

# 3. Target Users

Initial target audience:

-   Students managing academic responsibilities.
-   Working professionals managing everyday work and personal tasks.
-   Developers managing personal and professional to-dos.
-   People who forget small responsibilities.
-   People who prefer a simple task list over complex project
    management.

The initial product is an individual personal productivity application.
Team collaboration, shared workspaces and enterprise project management
are not part of the MVP.

------------------------------------------------------------------------

# 4. Platforms and Technology Decisions

## 4.1 Confirmed technology choice

The user has explicitly chosen:

-   **Flutter** for the mobile application.
-   **Dart** for application code and business logic.
-   **Kotlin** for Android-specific functionality.

Do not switch to React Native. The earlier React Native proposal was
superseded by the final decision to use Flutter + Dart + Kotlin.

## 4.2 Platform strategy

-   Android first.
-   Architecture should avoid unnecessary Android-only coupling in the
    Flutter application so that an iOS version can be considered later.
-   The floating overlay is Android-specific and must remain isolated in
    the Android native layer.

## 4.3 Proposed stack

  -----------------------------------------------------------------------
  Concern                             Technology
  ----------------------------------- -----------------------------------
  Mobile UI                           Flutter

  Language                            Dart

  Android native capabilities         Kotlin

  State management / dependency       Riverpod
  injection                           

  Navigation                          GoRouter

  Local database                      SQLite

  Dart database layer                 Drift

  Database path / Flutter integration drift_flutter or a verified
                                      compatible setup

  Data models                         Freezed + json_serializable where
                                      useful

  Date formatting                     intl

  Charts                              fl_chart or another suitable
                                      maintained package

  Animations                          Flutter animation APIs;
                                      flutter_animate where useful

  Icons                               Lucide-style Flutter icon package
                                      or consistent custom icons

  Unit tests                          flutter_test

  Mocking                             mocktail

  Integration tests                   integration_test

  Android IDE / SDK                   Android Studio and Android SDK

  Editor                              VS Code or Android Studio

  Version control                     Git
  -----------------------------------------------------------------------

Use stable, mutually compatible package versions. Verify current
compatibility before adding packages and commit `pubspec.lock`.

Do not install packages speculatively. Add dependencies as the
corresponding milestone requires them.

## 4.4 Backend strategy

No backend is required for the initial MVP.

The MVP must work without:

-   Account registration.
-   Login.
-   Internet access.
-   Cloud synchronization.

Cloud backup and multi-device synchronization may be considered in a
later version. Do not introduce a backend into the MVP without explicit
product approval.

------------------------------------------------------------------------

# 5. Brand Identity

## 5.1 Brand

**DAYFLOW**

Tagline:

> Your day. Your pace. Your progress.

Personality:

-   Calm, not boring.
-   Premium, not complicated.
-   Motivating, not demanding.
-   Minimal, but not empty.
-   Intelligent, but not overwhelming.

## 5.2 Official logo direction

The user selected a purple logo mark: an incomplete flowing circular
shape combined with a checkmark. The purple symbol shown and approved by
the user is the intended DAYFLOW logo.

Conceptual meaning:

-   The flowing/incomplete circle represents the continuous movement of
    a day and the journey of progress.
-   The checkmark represents accomplishment.
-   The circle should not imply that productivity must be perfect or
    that every day must reach 100%.

**Asset requirement:** Use the exact approved logo image/asset supplied
by the user when it is available in the project. Do not redraw it
differently or replace it with a generic calendar icon. If the source
asset is not available, create an asset placeholder/integration point
and ask for the approved image file.

## 5.3 Logo animation

The user wants the logo to have a subtle animation.

Recommended motion:

1.  **Splash launch:** The circular stroke draws itself, followed by the
    checkmark drawing in.
2.  **Task completion:** A small checkmark-draw or scale animation can
    reinforce task completion.
3.  **Loading:** Optional subtle lavender glow or opacity animation.
4.  **Floating bubble:** Very subtle breathing animation, with a setting
    to reduce or disable motion if appropriate.

Do not continuously spin the logo. Motion should be restrained, polished
and purposeful. Respect reduced-motion/accessibility preferences where
feasible.

------------------------------------------------------------------------

# 6. Approved UI/UX Direction

## 6.1 Overall visual direction

The user explicitly approved:

**Clean, elegant, productive, Apple-style productivity vibe.**

Tasks and typography are the main focus.

The UI should be:

-   Light theme by default.
-   Minimal and elegant.
-   Spacious, with intentional whitespace.
-   Typography-led.
-   Slightly colorful, but restrained.
-   Lavender-led, with occasional supporting colors.
-   Supported by subtle animations and micro-interactions.

The user approved a visual direction closer to clean Apple-style
productivity apps, not a generic colorful task dashboard.

## 6.2 What to avoid

Do NOT create:

-   Generic task-management templates.
-   Excessive glassmorphism.
-   Neon gradients everywhere.
-   Oversized progress rings.
-   Too many cards.
-   Decorative backgrounds that compete with tasks.
-   Heavy borders and shadows around every element.
-   Excessive colors.
-   Overly playful or childish visuals.
-   A corporate project-management look.
-   A dashboard where charts and illustrations are more prominent than
    tasks.

The earlier dark neon/glassmorphism concept was rejected. The later
clean light lavender/white direction was approved.

## 6.3 Color direction

Initial design tokens (these are starting values and may be tuned
consistently during implementation):

### Light theme

  Token              Value
  ------------------ -----------
  Background         `#FFFFFF`
  Surface            `#F8F6FC`
  Primary lavender   `#A98AFF`
  Secondary purple   `#7C5CFF`
  Main text          `#171526`
  Secondary text     `#77758A`
  Border/divider     `#EAE5F3`
  Success            `#44DE80`
  Danger             `#FF6B7A`

### Dark theme

  Token              Value
  ------------------ -----------
  Background         `#0B0B14`
  Surface            `#141424`
  Primary lavender   `#A98AFF`
  Secondary purple   `#7C5CFF`
  Main text          `#F5F5FF`
  Secondary text     `#A0A0B8`
  Border/divider     `#2A2840`
  Success            `#44DE80`
  Danger             `#FF6B7A`

Use lavender as the primary accent. Small amounts of green, blue, pink
or warm colors may distinguish categories or meaningful states. Do not
make every task a different bright color.

## 6.4 Typography

Preferred font direction: **Plus Jakarta Sans**.

Inter is an acceptable alternative if there is a licensing, rendering or
implementation reason.

Typography requirements:

-   Clear hierarchy.
-   Comfortable line height.
-   Excellent readability at mobile sizes.
-   Task titles should be prominent.
-   Metadata (time, category, date) should be quieter.
-   Avoid oversized headings that push tasks below the fold.

## 6.5 Spacing, shape and elevation

Starting design tokens:

-   Base spacing unit: 4 px.
-   Primary rhythm: 8 px increments.
-   Input radius: approximately 12 px.
-   Standard card radius: approximately 16 px.
-   Larger sheet/panel radius: approximately 24 px.
-   Use subtle elevation only when it communicates hierarchy.
-   Prefer separators and whitespace over unnecessary borders.

## 6.6 Animation

Recommended common interaction duration: approximately 180--250 ms,
adjusted to the interaction.

Use subtle, useful animation for:

-   Logo drawing.
-   Task completion.
-   Progress changes.
-   Bottom-sheet transitions.
-   Date selection.
-   Button press feedback.
-   Floating bubble expansion/collapse.

Animations should not slow down task entry or make the app feel busy.

------------------------------------------------------------------------

# 7. Application Navigation and Screens

The approved bottom navigation contains five destinations:

1.  Home
2.  Calendar
3.  Notes
4.  Insights
5.  Settings

Task creation/editing should be a shared flow accessible from Home and
Calendar, not a separate permanent bottom tab.

The following major screen designs have been reviewed and approved as
concepts. Preserve their visual direction when implementing. The actual
image/design reference assets should be added to the repository if
available.

## 7.1 Splash Screen

Purpose: - Establish DAYFLOW brand identity. - Show the official purple
flowing-circle/checkmark logo. - Play a restrained logo-draw
animation. - Transition smoothly to the application.

Requirements: - No unnecessary loading screen. - Do not delay app launch
for decorative animation. - Respect Android launch/splash conventions. -
The Flutter animated splash may follow the native launch screen.

## 7.2 Onboarding

Purpose: - Explain the product simply. - Introduce daily tasks,
date-based organization and notes. - Introduce floating companion as
optional. - Allow skipping. - No mandatory login. - Do not request
overlay permission during onboarding.

Keep onboarding short and useful. Permission requests should occur when
the user enables the relevant feature.

## 7.3 Home Dashboard --- Approved

This is the most important screen and the primary daily experience.

Approved design hierarchy:

-   Top: DAYFLOW identity, profile/settings access and greeting.
-   Current date.
-   Horizontal date selector.
-   Small daily progress summary.
-   Main task list.
-   Completed tasks in a collapsible section.
-   Elegant quick-add action.
-   Bottom navigation.

Core requirements:

-   Tasks and typography are the primary visual focus.
-   Display tasks for the selected date.
-   Today is selected by default.
-   Show pending tasks clearly.
-   Completed tasks remain accessible but may be collapsed.
-   Progress updates immediately when a task is completed/reopened.
-   Empty state encourages adding the first task.
-   Support 100+ tasks without excessive UI problems; use efficient list
    rendering and avoid unnecessary widget rebuilds.
-   Keep progress visualization modest; do not let it dominate the
    screen.

## 7.4 Add / Edit Task --- Approved

The user approved a compact, expandable bottom-sheet approach.

Interaction:

1.  User taps the `+` action.
2.  Quick Add opens.
3.  Task title receives keyboard focus immediately.
4.  User enters title.
5.  Date defaults to today unless launched from a selected calendar
    date.
6.  User can save quickly.
7.  Additional settings are optional and can be expanded.

Task fields:

-   Title (required).
-   Scheduled date (required, defaults to today).
-   Description (optional).
-   Reminder (optional).
-   Priority (optional).
-   Category (optional).

Additional UX: - Quick Add must remain compact. - Advanced fields must
not overwhelm the user. - Save/Update actions should be easy to reach. -
Editing uses the same form/component with existing values. - Provide
validation and clear error states. - Prevent accidental data loss when
dismissing an edited form with unsaved changes, where appropriate.

## 7.5 Calendar --- Approved

Purpose: navigate dates and understand which days contain tasks or
notes.

Requirements:

-   Monthly calendar.
-   Previous/next month navigation.
-   Selected date clearly highlighted in lavender.
-   Small indicators for dates containing tasks.
-   Separate or distinguishable indication for notes, without clutter.
-   Selected date's task list below the calendar.
-   Show completion status, time and priority where relevant.
-   Quick add for selected date.
-   Add Task form receives the selected date automatically.
-   Avoid overcrowding calendar cells.

The calendar is for date navigation and schedule overview, not a second
full task-management dashboard.

## 7.6 Notes --- Approved

The Notes section should feel like a lightweight personal notebook, not
a complicated document editor.

Notes list: - Search. - Recent notes grouped by date. - Optional
categories such as Personal, Work and Ideas. - Pinned notes at top. -
Quick-create action.

Create/edit note: - Title. - Simple text content. - Basic formatting
where practical. - Bullet lists and checklists if supported cleanly. -
Optional category. - Optional associated date. - Optional linked task.

Note detail: - Comfortable reading layout. - Edit, pin, share and delete
actions. - Safe/automatic saving behavior.

Important: - Notes are independent entities. - A note does not require a
task or deadline. - A note may optionally be associated with a date or
task. - Do not turn MVP Notes into a complex Notion-like rich-text
editor.

## 7.7 Insights --- Approved

Purpose: help users understand their activity without feeling like they
are using a business analytics dashboard.

Daily: - Tasks completed. - Pending tasks. - Completion percentage. -
Daily progress. - Current consistency streak, if implemented
responsibly.

Weekly: - Tasks completed during the week. - Average completion rate. -
Most productive day. - Weekly completion trend.

Monthly: - Monthly completion. - Productivity trends. - Category
distribution. - Comparison with previous month.

Actionable highlights may include: - "Friday was your most productive
day." - "You completed more tasks than last week." - "You were most
active in your Work category."

All insights must be computed from real stored data. Never fabricate
statistics. Avoid guilt-based messages or pressure.

If there is insufficient history, show a useful empty/early-use state
rather than misleading charts.

## 7.8 Settings --- Approved

Main sections: - Profile (optional/local profile; no required
account). - Appearance. - Reminders. - Categories. - Floating
Companion. - Backup and Sync (future capability; do not imply it works
in MVP). - About DAYFLOW. - Privacy policy.

Appearance: - Light mode (default). - Dark mode. - Follow system. -
Accent customization only if it does not compromise design
consistency. - Readable text sizes.

Floating Companion: - Enable/disable. - Bubble size. - Opacity. -
Left/right positioning. - Quick actions. - Auto-collapse/visibility
preferences.

No mandatory account registration for MVP.

## 7.9 Floating Companion --- Approved concept, Android-native implementation

This is the major differentiating feature.

Four conceptual states:

1.  **Floating Bubble:** Small draggable DAYFLOW logo/checkmark with a
    subtle progress indicator.
2.  **Quick Actions:** Add task, open Today, Notes or other limited
    quick actions.
3.  **Expanded View:** Today's completion summary and 2--3 pending
    tasks, with completion controls.
4.  **Compact Mode:** Small progress indicator.

Behavior: - User explicitly enables feature in Settings. - Explain
overlay permission before opening Android settings. - Request
`SYSTEM_ALERT_WINDOW` permission only when needed. - Bubble appears when
enabled and permitted. - User can drag it. - Tap opens quick actions or
expanded task card. - User can complete a task or create a task. -
Updates persist immediately. - Bubble can be dismissed/disabled. -
Auto-collapse may be configurable. - Respect screen boundaries, system
UI, cutouts and gesture areas. - Never continuously interrupt the
user. - Do not use Accessibility Services solely to implement the
overlay.

Engineering: - Implement with Kotlin and Android `WindowManager` using
supported overlay window types. - The overlay must not depend on the
Flutter activity being visible. - Handle permission revocation. - Handle
service/process recreation and Android background execution
restrictions. - Evaluate foreground-service requirements for the actual
implementation and current Android target. - Avoid unnecessary
continuous polling. - Minimize battery consumption. - Do not promise
indefinite execution across all Android OEM battery policies.

------------------------------------------------------------------------

# 8. Functional Requirements

## FR-01 Onboarding

Short introduction, skippable, no account required, no early overlay
permission request.

## FR-02 Home

Show selected date's tasks, progress, pending list, collapsible
completed list, quick add and empty states.

## FR-03 Task CRUD

Create, read, update, delete, complete and reopen tasks.

## FR-04 Date organization

Today, Tomorrow, custom dates, calendar and upcoming tasks.

## FR-05 Notes

Independent notes with optional date/task association, pinning, search
and basic editing.

## FR-06 Reminders

Optional task reminders with permission handling and
cancellation/rescheduling when tasks change.

## FR-07 Progress

Calculate completion percentage from non-deleted tasks for the selected
day. Handle zero tasks without division by zero.

## FR-08 Carry Forward

Offer the user the option to move incomplete tasks: - All incomplete
tasks to tomorrow. - Selected tasks to tomorrow. - Keep tasks on
original dates.

Never move tasks automatically without confirmation. Preserve IDs and
creation timestamps.

## FR-09 Settings

Theme, notification preferences, categories, companion controls, privacy
and app information.

## FR-10 Floating bubble

Opt-in draggable Android overlay.

## FR-11 Expanded companion

Show daily progress and a small set of pending tasks; support completion
and quick add.

## FR-12 State synchronization

The app and overlay must read/write the same persistent data source. No
divergent duplicate task databases.

## FR-13 Recovery and lifecycle

Handle app process termination, service restart where permitted, reboot
behavior where justified, and permission revocation.

------------------------------------------------------------------------

# 9. Domain Model and Data Design

The following is the proposed logical data model. Adapt SQL types to
Drift/SQLite appropriately.

## 9.1 Task

``` dart
class Task {
  final String id;
  final String title;
  final String? description;

  // Calendar date, stored as YYYY-MM-DD.
  final String scheduledDate;

  final String? categoryId;
  final String priority; // low, medium, high

  final bool isCompleted;
  final int? completedAt;

  // UTC epoch milliseconds for an actual instant.
  final int? reminderAt;
  final String? reminderTimezone;

  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
}
```

## 9.2 Note

``` dart
class Note {
  final String id;
  final String? title;
  final String content;

  // Calendar date, stored as YYYY-MM-DD.
  final String noteDate;

  final String? categoryId;
  final String? linkedTaskId;

  final bool isPinned;

  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
}
```

## 9.3 Category

Proposed fields: - id - name - color/token - createdAt - updatedAt -
deletedAt (if soft deletion is used)

Use a small sensible set of default categories if appropriate, but allow
the user to manage categories. Do not force category selection during
task creation.

## 9.4 Reminder

A separate reminder table may be used if reminder functionality grows
beyond one reminder per task. For the initial model, a nullable reminder
timestamp on Task may be sufficient. Make the decision based on actual
requirements; avoid premature complexity.

## 9.5 App settings

Store persistent preferences such as: - theme mode - selected accent (if
supported) - notification preferences - companion enabled state -
companion position/size/opacity - onboarding completion

Do not store sensitive information unnecessarily.

## 9.6 Data rules

-   Use UUIDs for persistent entity IDs.
-   Use SQLite transactions for multi-step operations.
-   Use foreign keys where appropriate.
-   Add indexes for common date/status queries.
-   Use parameterized queries.
-   Implement schema migrations.
-   Soft deletion may be used to support undo/recovery.
-   Do not silently delete tasks or notes.
-   Keep createdAt stable on edits.
-   Update updatedAt on modifications.
-   Completion should set completedAt; reopening should clear it.
-   Deleted tasks must not count in progress.
-   Task scheduled date is a calendar date, not a UTC timestamp.
-   Reminder time is a point in time and should be stored as UTC epoch
    milliseconds, with timezone context as needed.

### Timezone and date handling

This is important:

-   `scheduledDate` is a local calendar date (`YYYY-MM-DD`).
-   `reminderAt` is an instant (UTC epoch milliseconds).
-   Use explicit date utilities and tests.
-   Do not parse a date-only string as UTC midnight and then
    accidentally shift it to another local date.
-   Handle timezone changes and travel.
-   Define and test what happens when a reminder's local timezone
    changes.

------------------------------------------------------------------------

# 10. Architecture and Code Organization

Use a feature-first architecture with clear separation between
presentation, domain logic and data access.

Suggested structure:

``` text
dayflow/
├── android/
│   └── app/src/main/kotlin/com/dayflow/dayflow/
│       ├── MainActivity.kt
│       ├── overlay/
│       │   ├── FloatingService.kt
│       │   ├── OverlayManager.kt
│       │   ├── BubbleView.kt
│       │   └── ExpandedTaskView.kt
│       ├── database/
│       │   └── NativeTaskRepository.kt
│       ├── notifications/
│       │   ├── ReminderScheduler.kt
│       │   └── ReminderReceiver.kt
│       └── bridge/
│           └── DayflowBridge.kt
│
├── assets/
│   ├── images/
│   ├── icons/
│   ├── fonts/
│   └── animations/
│
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router/
│   │   └── theme/
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── extensions/
│   │   ├── utils/
│   │   └── widgets/
│   ├── features/
│   │   ├── onboarding/
│   │   ├── home/
│   │   ├── tasks/
│   │   ├── calendar/
│   │   ├── notes/
│   │   ├── insights/
│   │   ├── settings/
│   │   └── companion/
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   ├── daos/
│   │   └── migrations/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   └── shared/
│       ├── models/
│       ├── services/
│       └── providers/
│
├── test/
├── integration_test/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

Inside each feature, organize code by presentation/application/data as
appropriate. Do not create empty layers or boilerplate solely to match
the diagram.

Example:

``` text
features/tasks/
├── data/
│   ├── repositories/
│   └── mappers/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── screens/
    ├── widgets/
    └── providers/
```

Architecture rules:

-   UI widgets do not execute SQL.
-   UI widgets do not call Android APIs directly.
-   Business logic belongs in use cases/domain services.
-   Repositories abstract persistence.
-   Drift DAOs own query definitions.
-   Riverpod provides dependencies and reactive state.
-   Derived statistics should be calculated from actual database data.
-   Avoid giant files and god classes.
-   Avoid unnecessary abstractions and overengineering.

------------------------------------------------------------------------

# 11. Flutter and Kotlin Database Integration

This is a key architectural risk and must be implemented deliberately.

## 11.1 Desired behavior

The Flutter app and Android floating service must access the same SQLite
database file.

Example: 1. User creates a task in Flutter. 2. Flutter/Drift persists
the task. 3. User leaves the main app. 4. Kotlin floating service
remains available when Android permits. 5. User completes a task in the
floating view. 6. Kotlin updates the shared SQLite database. 7. When
Flutter resumes, the dashboard reflects the updated task.

## 11.2 Proposed approach

-   Drift owns the schema and migrations.
-   Use a known, app-private database file path that both Flutter and
    Kotlin can access.
-   Kotlin performs only the required native-side operations against the
    same SQLite database.
-   Kotlin must not independently create a competing schema or run its
    own migration system.
-   Define a stable database contract and version.
-   Coordinate database access and transactions carefully.
-   Use WAL mode only after verifying correct cross-process behavior
    with the selected SQLite setup.
-   Do not keep a long-lived Dart database connection in a separate
    process; Flutter and Kotlin run in the same app process in normal
    architecture, but native service lifecycle and database handles
    still require careful management.
-   Notify Flutter of native-side changes using a platform channel/event
    stream or refresh strategy.
-   Test simultaneous access, locking, transactions, migration, process
    death and app restart.

**Important implementation gate:** Before building the full overlay,
create a small proof of concept proving that Kotlin can safely
read/write the same database created by Drift. If the selected Drift
setup makes safe shared access impractical, evaluate a single
native-owned database/repository accessed by both sides through a typed
platform interface. Do not ship two independent databases that can
diverge.

------------------------------------------------------------------------

# 12. Android Native Floating Companion

## 12.1 Native components

Kotlin module should own: - Overlay permission checks. - Opening the
Android overlay settings page. - WindowManager overlay
creation/removal. - Bubble positioning and drag gestures. - Expanded
floating view. - Native task read/update operations. - Notification
scheduling integration. - Service lifecycle and supported recovery
behavior.

Flutter should own: - Companion settings UI. - Permission explanation
screens. - Enabling/disabling controls. - Companion configuration. -
App-side state and user experience.

## 12.2 Platform communication

Use Flutter platform channels or Pigeon for typed communication.

Potential interface:

``` dart
abstract interface class CompanionService {
  Future<bool> hasOverlayPermission();

  Future<void> requestOverlayPermission();

  Future<void> start();

  Future<void> stop();

  Future<bool> isRunning();

  Future<void> updateConfiguration(
    CompanionConfiguration configuration,
  );
}
```

The exact method design can be refined during implementation.

## 12.3 Android restrictions

-   Request overlay permission only when the user enables the feature.
-   Clearly explain why permission is needed.
-   Use supported overlay window types.
-   Respect Android background execution and foreground-service rules
    for the target SDK.
-   Do not use Accessibility Services solely for overlay functionality.
-   Do not promise indefinite background operation.
-   Handle permission revocation.
-   Handle screen lock and device shutdown appropriately.
-   Make the feature easy to disable.
-   Avoid excessive wakeups, polling or battery usage.
-   Do not show the overlay over sensitive/system UI where
    inappropriate.

------------------------------------------------------------------------

# 13. Reminders and Notifications

MVP supports optional local task reminders.

Requirements: - User can set a reminder for a task. - Schedule
notification using a suitable Android mechanism. - Cancel/reschedule
when task reminder changes. - Cancel when task is completed or
deleted. - Respect notification permission. - Handle app restart and
device reboot as supported. - Avoid exact alarm permission unless exact
timing is genuinely necessary and policy-compliant. - Explain
notification settings and permission denial gracefully.

Evaluate WorkManager, AlarmManager and suitable Flutter plugins based on
reminder timing requirements and current Android policy. Do not choose a
mechanism without understanding its precision and battery implications.

------------------------------------------------------------------------

# 14. State Management

Use Riverpod.

Do not place all application data in one global state object.

Persistent state: - Tasks. - Notes. - Categories. - Settings.

These belong in the database and repository layer.

UI state: - Selected calendar date. - Open modal/bottom sheet. -
Expanded completed section. - Temporary form values. - Selected
filters. - Loading and transient interaction state.

Derived state: - Daily task count. - Completion percentage. -
Weekly/monthly statistics. - Category distribution.

Derived values should come from database queries or domain calculations.
Avoid maintaining duplicate counters that can become inconsistent.

------------------------------------------------------------------------

# 15. Navigation

Five primary bottom destinations:

-   Home
-   Calendar
-   Notes
-   Insights
-   Settings

Additional routes: - Task creation/edit. - Note editor/detail. -
Category management. - Reminder configuration. - Appearance settings. -
Companion settings.

Use GoRouter. Keep navigation state predictable and handle Android back
navigation correctly.

The same task form should be reused from Home and Calendar. Calendar
should pass its selected date to the task creation flow.

------------------------------------------------------------------------

# 16. Accessibility and UX Quality

-   Maintain readable contrast.
-   Support system text scaling where practical.
-   Use semantic labels for controls.
-   Make touch targets comfortably large.
-   Provide screen-reader descriptions.
-   Respect reduced-motion preferences where feasible.
-   Ensure keyboard behavior is correct in forms and bottom sheets.
-   Avoid relying on color alone to communicate priority or completion.
-   Test on small and large Android screens.

------------------------------------------------------------------------

# 17. Testing Strategy

## Unit tests

Test: - Task creation and validation. - Task completion/reopening. -
Progress calculations. - Date calculations. - Carry Forward behavior. -
Reminder scheduling decisions. - Insights calculations. -
Repository/use-case behavior.

## Database tests

Test: - CRUD. - Foreign keys. - Transactions. - Migrations from previous
versions. - Soft deletion/undo. - Indexes and date queries. -
Cross-process Kotlin/Drift access.

## Widget tests

Test: - Home dashboard. - Task list items. - Add/edit form. - Calendar
selection. - Notes list/editor. - Theme changes. - Empty and error
states.

## Integration tests

Test: - Complete task creation flow. - Task completion updates
progress. - Calendar-selected date is passed to task form. - Notes
persist after restart. - Reminders schedule/cancel correctly. - Overlay
permission and start/stop flow. - Kotlin updates are reflected in
Flutter. - App process termination and reopening.

## Device testing

Test: - Multiple screen sizes. - Supported Android versions. - Different
manufacturers. - Notification permission denied. - Overlay permission
denied/revoked. - Battery optimization. - Device reboot. - Timezone
changes. - Keyboard and system navigation.

------------------------------------------------------------------------

# 18. Non-Functional Requirements

## Performance

-   Fast startup.
-   Immediate local task creation.
-   Responsive completion interaction.
-   Efficient database queries.
-   Smooth scrolling.
-   Avoid unnecessary widget rebuilds.
-   Avoid expensive work on the UI thread.

## Reliability

-   Data persists across normal app lifecycle events.
-   Safe schema migrations.
-   Transactional updates.
-   Graceful failure handling.
-   No silent data loss.
-   Correct reminder cancellation/rescheduling.

## Security and privacy

-   No mandatory account.
-   No unnecessary personal data.
-   No analytics that collect task content.
-   App-private local storage.
-   Secure export handling.
-   Clear privacy policy.
-   Minimum required Android permissions.

------------------------------------------------------------------------

# 19. Development Roadmap

Implement in the following order.

## M1 --- Environment and project setup

-   Install Flutter stable SDK.
-   Configure Dart and Android Studio/SDK.
-   Verify `flutter doctor`.
-   Create Flutter project.
-   Configure Android package/application ID.
-   Configure Git.
-   Run initial Android build.
-   Add baseline linting and formatting.

## M2 --- Design system

-   Official logo asset integration.
-   Typography.
-   Light and dark themes.
-   Color tokens.
-   Spacing/radius tokens.
-   Buttons, inputs and common components.
-   Logo animation.
-   Splash experience.

## M3 --- Database foundation

-   Drift setup.
-   SQLite schema.
-   Entities/tables.
-   DAOs.
-   Repositories.
-   Migrations.
-   Date utilities.
-   Database tests.

## M4 --- Core task management

-   Home dashboard.
-   Quick Add.
-   Add/Edit Task.
-   Completion/reopening.
-   Delete/undo.
-   Progress calculation.
-   Empty states.

## M5 --- Calendar

-   Monthly navigation.
-   Selected date.
-   Task/note indicators.
-   Selected-day task list.
-   Quick add with selected date.

## M6 --- Notes

-   Notes list.
-   Search.
-   Pinning.
-   Create/edit/detail.
-   Optional date/task association.

## M7 --- Reminders and settings

-   Local reminders.
-   Permission flows.
-   Appearance settings.
-   Categories.
-   Settings screen.

## M8 --- Insights

-   Daily/weekly/monthly statistics.
-   Real-data charts.
-   Empty/insufficient-history states.
-   Actionable highlights.

## M9 --- Floating companion proof of concept

Before full UI implementation: - Verify shared database access. - Verify
overlay permission. - Create draggable bubble. - Test app
closed/background behavior. - Verify native task completion updates the
same database.

Then implement: - Expanded task card. - Quick actions. - Quick add. -
Configuration. - Lifecycle and battery handling.

## M10 --- Production readiness

-   Full testing.
-   Accessibility.
-   Performance profiling.
-   Crash/error handling.
-   Privacy policy.
-   App icon and Play Store assets.
-   Signing configuration.
-   Internal/closed testing.
-   Production release.

Keep the app building at each milestone.

------------------------------------------------------------------------

# 20. Play Store and Monetization Direction

Initial release should prioritize product quality and trust.

Do not add advertisements in the MVP. The product is intended to help
users focus, and intrusive ads would conflict with its purpose.

Potential future free/pro model:

Free: - Unlimited basic tasks. - Daily notes. - Calendar. - Basic
reminders. - Basic progress. - Light and dark themes.

Potential Pro: - Advanced insights. - Additional themes/customization. -
Cloud synchronization. - Advanced reminder options. - Advanced floating
companion customization.

Do not implement subscriptions or payments in the MVP without explicit
approval.

Play Store preparation will include: - Unique application ID. - App
signing. - App icon. - Screenshots. - Feature graphic. - Privacy
policy. - Data Safety declarations. - Permission justification. -
Testing and production rollout.

------------------------------------------------------------------------

# 21. Definition of Done

A feature is not complete merely because its screen looks correct.

A feature is done when: - UI matches the approved design direction. -
Loading, empty, success and error states are handled. - Business rules
are implemented. - Data persists correctly. - Validation is present. -
Relevant tests pass. - No major accessibility issue is known. - Static
analysis passes. - Android build succeeds. - No critical/high-severity
defect remains.

------------------------------------------------------------------------

# 22. Immediate First Milestone --- M1

The first implementation objective is intentionally small.

1.  Verify Flutter/Dart installation.
2.  Verify Android Studio and SDK.
3.  Run `flutter doctor -v`.
4.  Create the `dayflow` project.
5.  Confirm Android package identity.
6.  Run on emulator or physical Android device.
7.  Configure Git and baseline project quality.
8.  Display a basic DAYFLOW app shell.

Do not begin the full feature implementation before the starter app
builds successfully.

The next milestone is the design system and animated logo splash.

------------------------------------------------------------------------

# 23. Final Product Summary

DAYFLOW is an Android-first, offline-first personal productivity
companion built with Flutter, Dart and Kotlin.

It combines: - A clean, elegant, Apple-style daily task dashboard. -
Fast task creation for today, tomorrow or a custom date. - A simple
monthly calendar. - Independent daily/personal notes. - Encouraging
productivity insights. - Optional reminders. - A distinctive Android
floating task companion. - Light and dark themes. - Local-first data
storage without mandatory registration.

The most important product differentiator is the optional floating
companion, which allows users to view and update today's tasks without
repeatedly opening the full application.

The most important design rule is that tasks and typography remain the
focus. Use whitespace, restrained lavender color, subtle animation and a
calm visual hierarchy.

**Product philosophy: Capture quickly. Focus clearly. Complete
peacefully.**

**End of DAYFLOW project brief.**
