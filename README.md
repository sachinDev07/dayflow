# DAYFLOW

Your day. Your pace. Your progress.

Android-first, offline-first personal productivity companion built with Flutter, Dart, and Kotlin.

## Product scope

[DAYFLOW_PROJECT_DETAILS.md](DAYFLOW_PROJECT_DETAILS.md) is the approved product specification. [M1_IMPLEMENTATION_PLAN.md](M1_IMPLEMENTATION_PLAN.md) records the initial assessment and ordered setup plan.

M1 is complete and committed in `4bf3f06`. M2 implements the design system using the supplied [design references](design-preferences/) and [approved logo](design-preferences/dayflow_app_icon.png), committed in `0f54526`. M3 adds the offline database foundation in `af80e6c`. The project uses Kotlin and application ID `com.dayflow.dayflow`. See [M2_DESIGN_SYSTEM.md](M2_DESIGN_SYSTEM.md) for design decisions and [M3_DATABASE_FOUNDATION.md](M3_DATABASE_FOUNDATION.md) for persistence architecture, data rules, verification, and the future Kotlin database contract.

The app opens Home and provides Home, Calendar, Notes, Insights, and Settings navigation through GoRouter, with Riverpod provisioning and disposal of the router. Top-level tab changes replace the destination rather than accumulating history. Android Back returns to Home from another tab, then exits from Home. The shell uses the supplied logo, bundled Plus Jakarta Sans, Lucide line icons, compact headings, pale lavender surfaces, and purple selected navigation. M4 connects Home to saved tasks; later destinations remain clearly marked as coming soon. See [M4_CORE_TASK_MANAGEMENT.md](M4_CORE_TASK_MANAGEMENT.md) for implementation decisions and verification.

Both light and dark design themes exist, with light as the product default. Stored theme preferences are available in M3; applying them and user-facing appearance settings belong to M7. Home now provides date selection, real task progress, pending/completed lists, Quick Add/Edit, completion/reopening, and delete/undo. The shared sheet follows the approved v4 task flow and protects unsaved drafts. Calendar, notes UI, reminders, insights, and the native companion remain later milestones.

## Development environment

Setup started on 16 November 2026 (Asia/Calcutta).

| Tool | Version or location | Verification |
| --- | --- | --- |
| Flutter | 3.50.0 stable, `C:\src\flutter` | `flutter --version` passed |
| Dart | 3.14.0, bundled with Flutter | `dart --version` passed |
| Java | Temurin OpenJDK 17.0.21 | Existing installation; selected explicitly for Flutter builds |
| Git | 2.56.0.windows.2 | Available; local repository initialized on `main` |
| Android Studio | 2026.2.2, installed through Windows Package Manager | Installer completed successfully |
| Android SDK | `C:\src\android-sdk` | SDK manager verification passed; Flutter doctor Android toolchain passed |
| Android command-line tools | 22.0 | Archive SHA-256 verified before installation |
| VS Code Flutter/Dart extensions | 3.146.0 | Installation completed successfully |
| Gradle | 9.5.0, project wrapper | `gradlew.bat --version` passed with Java 17 |
| Android emulator | 37.2.13, `DAYFLOW_API_36` | Booted Android 16/API 36; shell runtime checks passed |
| Windows Hypervisor Platform | Enabled | `emulator -accel-check` confirms WHPX is installed and usable |

Flutter's first invocation also downloaded its Dart SDK and version metadata. Flutter command-line analytics are disabled. No application analytics are configured.

The existing Java installation was retained. Flutter is explicitly configured to use it, rather than automatically selecting Android Studio's bundled runtime. When opening the Android module in Studio, select the same JDK for Gradle builds; the IDE itself can keep its bundled runtime.

### Terminal setup

User PATH now includes:

```text
C:\src\flutter\bin
C:\src\android-sdk\platform-tools
C:\src\android-sdk\emulator
C:\src\android-sdk\cmdline-tools\latest\bin
```

`ANDROID_HOME` is set to `C:\src\android-sdk`. Existing PATH entries and the existing `JAVA_HOME` were preserved. Restart VS Code and open a new terminal to pick up these changes.

Installed Android packages match the selected Flutter template: API 36 (revision 2), Build Tools 36.0.0, NDK 28.2.13676358, Platform Tools 37.0.1, Emulator 37.2.13, and one Google APIs x86_64 API 36 system image (revision 7). Direct SDK package verification returned exit code 0. Android SDK licenses are accepted, and Flutter's Android engine/build artifacts are cached.

The M3 native dependency build additionally installed SDK Platform 35 and CMake 3.22.1. The application still compiles and targets API 36 with minimum API 24.

The final `flutter doctor -v` passed the Flutter and Android toolchain checks with the updated PATH. Android Studio's installation directory is also configured explicitly in Flutter. A Windows desktop C++ tooling warning is unrelated to this Android-only project; those additional desktop components were not installed.

### Emulator acceleration

CPU virtualization is enabled in firmware. Setup enabled Windows Hypervisor Platform without automatically restarting the computer. On resuming work, `emulator -accel-check` returned 0 and confirmed WHPX is installed and usable; the reboot requirement is resolved.

To verify the environment:

```powershell
flutter --version
dart --version
flutter doctor -v
emulator -accel-check
flutter emulators
flutter devices
```

The Pixel 6 virtual device `DAYFLOW_API_36` uses the API 36 Google APIs x86_64 image and 2 GB RAM. Device verification ran with the emulator in the background, software rendering, and a 720×1600 display override at density 280. The initial 1080×2400 cold boot showed an emulator System UI timeout. Reducing the display resolution made it responsive; no DAYFLOW crash was observed in the checked logs. These debug/emulator checks do not establish production startup performance or physical-device coverage.

To launch the emulator normally after closing any running instance:

```powershell
flutter emulators --launch DAYFLOW_API_36
flutter devices
```

## Development commands

Run these from the repository root after installing the documented toolchain:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
flutter run -d <android-device-id>
```

Use an actual Android ID reported by `flutter devices` in place of the placeholder. Dependency versions are resolved in `pubspec.lock`. The Android Gradle template currently pins Gradle 9.5.0 and AGP 9.3.1 with Kotlin plugin metadata 2.4.20; Java/Kotlin compilation targets version 17. Flutter supplies minimum API 24 and compile/target API 36.

The generated starter passed analysis, its widget smoke test, and an Android debug build before replacement. M1 verification then passed:

- Formatting verification: 9 Dart files, no changes required.
- `flutter analyze`: no issues found.
- `flutter test`: 2 tests covering destination navigation, selection, Back-to-Home behavior, and a 320×568 viewport with 200% text scaling.
- `flutter build apk --debug`: succeeded.
- Android 16/API 36 emulator checks: all five tabs, selected-tab accessibility state, Back-to-Home, Back-from-Home exit, background/resume, and fresh process relaunch.
- APK metadata: DAYFLOW label, `com.dayflow.dayflow`, minimum API 24, target API 36.

The local APK is `build/app/outputs/flutter-apk/app-debug.apk`; a verified M1 Home screenshot is `build/m1-home.png`. Both are ignored build artifacts. M1's initial shell had no persistence or task functionality.

The resolved dependencies include Riverpod 3.5.0, GoRouter 18.1.4, and Lucide Icons Flutter 4.0.3. Flutter 3.50's generated template uses `material_ui` (resolved to 1.11.0); the shell retains that UI foundation. M3 adds Drift, drift_flutter, path_provider, UUID, and database code-generation/test tooling. Chart, notification, and overlay packages have not been added.

## M2 design-system preview

The app's shared design system follows `design-preferences/`, using the v4 task-flow board over earlier revisions. Poster backgrounds, sample tasks, and sample statistics are not copied into application data. Buttons use a darker purple gradient than the posters for readable white labels.

The separate developer preview allows checking component states and light/dark themes without introducing unfinished feature controls into product routes:

```powershell
flutter run -t tool/design_preview.dart -d <android-device-id>
```

The preview's controls are temporary UI state only. Run the normal app again with `flutter run -t lib/main.dart` after previewing. Include `tool` when checking formatting: `dart format --output=none --set-exit-if-changed lib test tool`.

M2 verification completed on 18 November 2026:

- Formatting: 21 Dart files, no changes required; static analysis: no issues.
- All 8 tests passed, covering theme contrast, offline asset loading, light-default/system-theme behavior, reduced motion, validation and sheet reachability, disabled actions, tab navigation, and large text. A large-text wordmark overflow found during development was corrected.
- Both the separate component-preview APK and final main Android debug APK built successfully.
- Android 16/API 36 emulator: light/dark component previews reviewed, keyboard-aware sheet opened and closed with its action above the keyboard, final Home reviewed, all five destinations exercised, and Android Back returned to Home. No Flutter layout errors appeared in the checked runtime logs.
- The final APK contains the exact approved logo, both offline fonts, and the font license. The preview was replaced with the main APK after component verification.

Local screenshots are `build/m2-home.png`, `build/m2-preview-light.png`, `build/m2-preview-dark.png`, and `build/m2-preview-sheet.png`. The main app is `build/app/outputs/flutter-apk/app-debug.apk`; `build/m2-components-preview.apk` is for component review only. Build artifacts are ignored by Git.

The emulator had slow cold boots and System UI timeouts on this host. Builds and emulator checks were serialized after memory pressure was observed; Gradle was stopped before device verification. Successful checks used the 720×1600 software-rendered Android 16 emulator. Physical devices and older Android versions have not been exercised in M2, and these results do not establish production startup performance.

## M3 database foundation

SQLite schema version 1 contains tasks, notes, categories, and singleton app settings. Drift owns schema creation and future migrations. DAOs and repository interfaces support reactive reads, transactional writes, completion/reopening, soft deletion/restoration, and optional associations. No sample tasks or statistics are seeded. Calendar dates use validated `YYYY-MM-DD` text; timestamps use UTC epoch milliseconds.

The single lazy Riverpod database uses the application support directory. Android's matching native location is `File(context.filesDir, "dayflow.sqlite")`; `context.getDatabasePath()` would select a different file. Kotlin access and concurrent writers still require M9 verification. M3 preserved the shell appearance; M4 connects the task repositories to Home and task forms without changing the schema.

After changing table definitions, regenerate runtime code and preserve schema history:

```powershell
dart run build_runner build
dart run drift_dev make-migrations
dart run drift_dev schema generate drift_schemas/app_database test/database/migrations/generated
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter build apk --debug
```

Future schema versions also need explicit migration steps and data-preservation tests; generation alone does not implement an upgrade. The committed v1 snapshot verifies new and existing v1 databases. File-backed tests check persistence and rejection of unsupported newer schemas without deleting data.

For developer-only Android persistence verification:

```powershell
flutter run --no-resident -t tool/database_smoke.dart -d <android-device-id>
```

This tool creates uniquely identified temporary records, closes/reopens the real database, verifies persistence and integrity, then removes only its own fixtures. Run the regular application afterward with `flutter run -t lib/main.dart -d <android-device-id>`. See the M3 document for final verification results.

## M4 task workflows

Home uses reactive date queries and derives progress from actual non-deleted tasks. Quick Add defaults to the selected Home date and expands to priority, an existing category, and description. Editing preserves IDs, creation timestamps, completion state, and existing reminder metadata. Blank titles cannot be saved. Failed saves retain the draft, and dirty forms ask before discarding.

Completed tasks can be expanded and reopened. Deletion asks for confirmation and provides Undo; there is no automatic task movement. Lists render lazily, with tests exercising 110 tasks. Today refreshes across midnight/resume while explicit date selections remain stable.

Reminder controls/scheduling and category management remain M7; Calendar is M5 and will reuse this task form. No new packages, schema changes, native services, or permissions are added in M4. Detailed checks and local Android artifacts are recorded in the M4 document.

M4 verification completed on 18 November 2026: all 38 tests passed, analysis and formatting passed, and the final Android debug APK built successfully. Android 16/API 36 emulator checks verified creation, completion/reopening, editing, delete/undo, and persistence after force-stop/relaunch. The temporary task was soft-deleted after verification. The final APK is `build/app/outputs/flutter-apk/app-debug.apk`; a final Home screenshot is `build/m4-home-final.png`. M5 (Calendar) is next.

## Version control

The local branch is `main`; the user has configured the Git author and an `origin` remote. The local history contains M1 (`4bf3f06`), M2 (`0f54526`), and M3 database implementation (`af80e6c`). These checks do not establish whether the user has pushed those commits.

Git trust is limited to this exact workspace through a `safe.directory` entry because the repository was initially created by the sandbox account. The approved brief's original content and existing whitespace are preserved.

Generated files, local SDK paths, build outputs, caches, and signing credentials are excluded by `.gitignore`. The application lockfile and complete Gradle wrapper are included in the source baseline. No remote has been contacted for publication.

## Brand assets

The exact supplied `dayflow_app_icon.png` is bundled unchanged for Flutter and Android launch. The header frames its central icon at runtime. Native splash configuration uses the original artwork, including on Android 12+, and the ready brand header fades in over 220ms without holding startup. Reduced motion skips the fade. A true circle/checkmark stroke draw would require the approved vector paths; no substitute logo is drawn.

Plus Jakarta Sans normal/italic fonts and their SIL license are bundled for offline use, with the license registered in Flutter's license registry. Provenance and checksums are in the M2 design-system document. Production launcher/store artwork remains M10; the generated launcher icon is still temporary.

## Setup references

- [Flutter installation](https://docs.flutter.dev/install/manual)
- [Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup)
- [Android emulator acceleration](https://developer.android.com/studio/run/emulator-acceleration)
- [Android Gradle Plugin 9.3 compatibility](https://developer.android.com/build/releases/agp-9-3-0-release-notes)
