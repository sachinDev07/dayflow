# M3: offline database foundation

Completed 18 November 2026 (Asia/Calcutta), from M2 commit `0f54526`; the database implementation is committed in `af80e6c`. The approved product brief and design references remain unchanged. This milestone adds persistence infrastructure; it does not connect task forms, add visible features, or change appearance.

## Architecture

`AppDatabase` owns schema version 1, creation, connection configuration, and DAOs. Four feature repositories implement persistence-independent interfaces for tasks, notes, categories, and settings. Domain entities and calendar-date types contain no Flutter or Drift types. DAOs own query definitions; application widgets do not execute SQL or Android APIs.

`database_providers.dart` supplies one lazy database per Riverpod `ProviderScope` and the four repository interfaces. Disposing the scope closes the connection. Tests can inject an isolated database and deterministic clock/UUID factory. The current screens do not read these providers; M4 will be the first production task-data consumer. There is no database initialization delay or new error/loading screen in the M2 UI.

`drift_flutter` opens the SQLite connection on one background Dart isolate in the normal Android application process. There is no second Android service process, read pool, backend, login, or competing native database.

Resolved direct dependencies: Drift 2.35.4, drift_flutter 0.3.1, path_provider 2.1.6, UUID 4.6.0. Development tools are drift_dev 2.35.3, build_runner 2.17.1, and sqlite3 3.9.1 for direct integrity tests. sqlite3 is also a transitive runtime dependency of Drift. Current native SQLite is provided through package native assets; no legacy SQLite library package was added directly.

## Data decisions

| Entity | Stored data and rules |
| --- | --- |
| Tasks | UUID, trimmed nonempty title, optional description/category/priority, required `scheduled_date`, completion state/time, optional reminder instant/timezone context, created/updated/deleted times |
| Notes | UUID, optional trimmed title, plain text content, optional date/category/task association, pin state, created/updated/deleted times |
| Categories | UUID, trimmed nonempty name, opaque `0xRRGGBB` color integer, created/updated/deleted times |
| App settings | One row with `id=1`, theme preference, reminder/companion opt-in flags, onboarding completion, companion side/size/opacity, updated time |

The prose requirements permit independent undated notes, so `note_date` is nullable despite the brief's non-null example field. Priority is also nullable to preserve its optional UX rather than silently assigning importance. Reminder timezone context is optional, but cannot exist without an instant. No extra reminder table is needed for one reminder per task.

Tasks, notes, and categories use generated UUID v4 IDs. The fixed settings row is an intentional singleton, not a user entity requiring a UUID. Its initial `updated_at=0` means unmodified defaults. Defaults are light theme, reminders off, companion off, onboarding incomplete, right side, size 56, opacity 1. No tasks, notes, categories, or statistics are seeded.

Settings values are storage only: writing an enabled flag does not request permissions, start a service, schedule reminders, or change the current UI. User-facing settings and platform reconciliation belong to M7/M9. Companion geometry validation currently permits 40–96 logical pixels and opacity 0.3–1; these are initial bounds for the stored preference, not a finalized overlay implementation.

All metadata and reminder instants are INTEGER UTC epoch **milliseconds**. Drift's `dateTime()` mapping is deliberately not used, so there is no implicit seconds/milliseconds mismatch with Kotlin. Creation timestamps are immutable through repository updates. Modification times come from an injectable UTC clock and are clamped to the previous update time when the device clock moves backwards.

Completion sets `completed_at`; reopening clears it. Repeating the existing completion/pin/delete state does not rewrite timestamps. Schema checks reject inconsistent completion/time fields. Deleted rows are excluded from normal reads and date queries, and can be read explicitly for recovery. No public repository method physically deletes user entities.

## Dates and travel

`LocalDate` validates Gregorian dates and stores exactly `YYYY-MM-DD`. It does not parse date-only strings as midnight instants. `fromDateTime` takes the supplied object's calendar components; callers explicitly choose their local/UTC time basis. `addDays` uses UTC internally only as a timezone-neutral arithmetic carrier, so DST never adds or removes a scheduled day. Invalid dates are rejected instead of normalized.

`ReminderInstant` represents an absolute UTC instant. Changing the display timezone or travelling does not move the stored reminder. The optional timezone identifier preserves context; it is not a validated timezone-rule database and does not schedule anything. M7 must define local-wall-time selection, DST gap/fold behavior, permission handling, precision, and rescheduling. Scheduled task dates remain unchanged during travel.

## Integrity, transactions, and indexes

Every connection enables `foreign_keys` and a 5000ms busy timeout. Related repository writes and read/modify/write state changes run in SQLite transactions. Schema creation and default settings insertion are transactional. Parameterized Drift expressions and companions bind user data; values are not interpolated into SQL.

Foreign keys connect tasks/notes to categories and notes to tasks. There is no cascading user-data deletion. New assignments require an existing active parent. Soft deletion retains historical links so independent notes survive and undo can restore relationships. Editing an existing historical link remains possible. Any future physical purge must explicitly handle references and retention rules.

SQLite constraints additionally check nonempty titles/names, calendar-date shape and actual validity, allowed priorities, completion consistency, metadata ordering, valid settings choices, and companion preference ranges. IDs have length checks; UUID generation/format is an application/native-writer contract. SQLite's built-in NOCASE supplies ASCII-case-insensitive active-category uniqueness. Restoring an archived category that conflicts with a newer active name fails without overwriting either row.

Indexes cover active task date/completion/order, active note pin/recent order, note date queries, and active category-name uniqueness. A query-plan test checks that the task date query uses its intended index with more than 100 tasks. Daily progress is not a duplicated stored counter; M4 derives it from active tasks.

New files use SQLite's default rollback journal (`delete`), verified in file-backed tests. M3 does not force a journal-mode change on existing files or enable WAL. WAL and simultaneous Dart/Kotlin writers remain an explicit M9 validation gate.

## Database contract for future Kotlin access

- File name: `dayflow.sqlite`.
- Flutter location: `getApplicationSupportDirectory()/dayflow.sqlite`.
- Android equivalent, verified against the installed path_provider implementation: `File(context.filesDir, "dayflow.sqlite")`.
- Do **not** use `context.getDatabasePath("dayflow.sqlite")`: that chooses a different directory and would create a divergent database.
- Resolve the private files directory at runtime; do not hardcode a `/data/user/0/...` path.
- `PRAGMA user_version` is 1. Drift alone creates tables and upgrades versions.
- SQL table/column names are snake_case: `tasks.scheduled_date`, `is_completed`, `completed_at`, `updated_at`, `deleted_at`, and so on. Booleans are SQLite 0/1 integers; IDs are UUID text; dates are date-only text.
- Native connections must enable foreign keys and a bounded busy timeout, verify the supported schema version, and never independently create or migrate a schema.
- Native task mutations must use transactions, preserve IDs/creation time, update modification time monotonically, respect soft deletion, and set/clear completion timestamps together with the flag.
- Native updates are not automatically visible to Drift's watch-query invalidation. M9 must add an explicit channel/event/refresh strategy and test foreground resume, locking, migration, process death, and concurrent access.

This contract does not claim Kotlin read/write compatibility has been proven. M9 must test the actual bundled SQLite/native Android SQLite combination before building the full companion. No overlay code or native repository is added in M3.

## Schema history and migrations

The committed baseline is `drift_schemas/app_database/drift_schema_v1.json`, with generated verification helpers in `test/database/migrations/generated/`. Generated runtime code is `lib/database/app_database.g.dart` and should be committed along with table changes.

There is no pre-M3 database schema to upgrade. Version 1 creates a new database; existing v1 files open without recreation. Unsupported version changes, including opening a newer database with this older app, throw while preserving the file and its original version/data. No deletion, destructive reset, or automatic downgrade fallback exists.

For future schema changes, preserve old snapshots, bump `schemaVersion`, generate migration scaffolding, implement each version step, and add data-preservation tests. Never edit an old snapshot to hide a schema change.

```powershell
dart run build_runner build
dart run drift_dev make-migrations
dart run drift_dev schema generate drift_schemas/app_database test/database/migrations/generated
dart format lib test tool
flutter analyze
flutter test
flutter build apk --debug
```

The explicit `schema generate` command creates v1 verification helpers even though there is not yet an upgrade step for `make-migrations` to scaffold. Snapshot tests compare fresh/current and existing-v1 schemas; newer-schema rejection and file persistence are separately exercised. These are not represented as a tested v1-to-v2 migration.

## Android verification tool

`tool/database_smoke.dart` is a developer-only alternate entry point. It opens the real production-location database, creates uniquely identified temporary category/task/note records, closes/reopens the connection, verifies persistence, relationships, file location, foreign keys, version and integrity, then deletes only those exact fixture IDs in child-first order. Existing user records and settings are not changed. Do not use it as a product feature.

```powershell
flutter run --no-resident -t tool/database_smoke.dart -d <android-device-id>
```

After verification, rebuild/run the regular `lib/main.dart` application so the delivered APK is the product shell, not the developer verification screen.

## Verification results

Verified on 18 November 2026 (Asia/Calcutta):

- Drift generation and v1 schema/helper generation succeeded. Formatting checks passed; `flutter analyze` reported no issues.
- All 28 tests passed: 8 existing design/shell tests, 4 date utility tests, 14 repository/integrity tests, and 2 schema baseline tests. Coverage includes reactive reads, optional-value clearing, relationships, soft deletion/restoration, category-name conflicts, timestamp rules, settings validation, transactional rollback, query index use, file persistence, and preserving data when a newer schema is rejected.
- Both the developer database verification APK and the regular main Android debug APK built successfully. The regular APK bundles native SQLite for ARM64, ARMv7, and x86_64, and retains the DAYFLOW label, `com.dayflow.dayflow`, minimum API 24, and target API 36.
- The developer check passed on the Android 16/API 36 x86_64 emulator using bundled SQLite **3.54.1**. Tasks and linked notes survived a complete database connection close/reopen at the production path. Schema version 1, enabled foreign keys, and `integrity_check=ok` were verified; only the check's temporary fixture IDs were removed.
- `adb shell run-as com.dayflow.dayflow ls -l files/dayflow.sqlite` independently confirmed the app-private file exists (53,248 bytes after the check). This validates the Android `context.filesDir` location rather than the separate Android databases directory.
- The regular main APK replaced the developer build successfully. Its unchanged Home screen was visually reviewed, with no Flutter errors in the checked main-process logs. `build/m3-home.png` records that screen; `build/m3-database-verification.png` records the successful developer result (with an emulator System UI timeout dialog). These are ignored local artifacts. The final product APK is `build/app/outputs/flutter-apk/app-debug.apk`; `build/m3-database-smoke.apk` is developer-only. The emulator was stopped after verification to free host memory.

Builds and emulator checks ran sequentially to limit memory pressure. The final check used 1,536 MB emulator RAM, 2 cores, software rendering, and a 720x1600 display override. Android cold boot and APK installation were slow, and an Android system-process timeout dialog appeared; the successful persistence result was confirmed in Flutter logs after fixture cleanup. These checks do not establish startup performance, physical-device coverage, older Android compatibility, or simultaneous Kotlin/Dart access.

The approved product brief, design references, product UI, and native application source remain unchanged by M3. The next milestone is M4: Home dashboard, Quick Add, Add/Edit Task, completion/reopening, delete/undo, progress calculation, and empty states using the approved v4 task-flow references.

## References

- [Drift setup and native connection options](https://drift.simonbinder.eu/setup/)
- [Drift native isolate behavior](https://drift.simonbinder.eu/platforms/vm/)
- [Drift migrations](https://drift.simonbinder.eu/migrations/)
- [Schema verification](https://drift.simonbinder.eu/migrations/tests/)
