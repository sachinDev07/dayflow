# DAYFLOW M1 implementation plan

Prepared: 16 November 2026 (Asia/Calcutta).

Status: M1 is complete. The environment, Android configuration, and application shell were verified, and the user committed the baseline as `4bf3f06`. See `README.md` for installed versions and verification evidence. The assessment below records the initial state before installation; M2 is documented separately.

The complete `DAYFLOW_PROJECT_DETAILS.md` v1.0 is the product source of truth. This plan implements its M1 scope and does not revise the approved product direction.

## 1. Current state compared with the specification

| Area | Observed state | M1 implication |
| --- | --- | --- |
| Repository contents | Only `DAYFLOW_PROJECT_DETAILS.md` existed before this plan. Hidden files were included in inspection. | Initialize the application in this directory; preserve the brief. |
| Flutter application | No `pubspec.yaml`, `lib/`, `android/`, tests, or application assets. | No existing application implementation to migrate or repair. |
| Flutter and Dart | Neither command resolves on PATH; no SDK found in the common locations inspected. | Install or locate a stable Flutter SDK, which supplies Dart. |
| Android tooling | Android Studio, `adb`, `sdkmanager`, and `avdmanager` not found through command lookup or inspected installation locations. Android SDK environment variables are unset. | Configure Android Studio and a usable Android SDK. |
| Installed-app evidence | A .NET Android manifest package is registered, but no Android Studio registration was found. | That package does not establish a working Flutter Android toolchain. |
| Java | Temurin OpenJDK `17.0.21+9` runs; `JAVA_HOME` points to its installation. | Preserve initially; verify compatibility with the selected Flutter template, Gradle, and Android Gradle Plugin (AGP). |
| Git | Git `2.56.0.windows.2` runs. This directory is not within a Git repository. Effective `user.name` and `user.email` are absent. | Initialize local version control and obtain the intended author identity before committing. |
| Editor | VS Code command is available. | Verify Flutter/Dart editor support during setup. |
| Device | No Android virtual-device definitions found in the standard user location. `adb`/Flutter are unavailable. | Device connectivity and emulator acceleration remain unverified. |
| Brand assets | No approved logo, font files, or screen reference images present. | M1 can use text branding; exact logo integration belongs to M2. |
| Local instructions | No `AGENTS.md` found in this workspace or its ancestor directories. | No additional repository-specific instructions discovered. |

These are bounded findings: tools could exist in custom locations. Absence from PATH and the inspected locations is not proof that software is absent from the entire machine.

`flutter doctor -v`, Flutter tests, and Android builds could not be run because Flutter is unavailable. No build or runtime success is claimed. M1 is the correct next milestone; later requirements are unimplemented rather than regressions.

## 2. Approach and boundaries

Use the current stable Flutter Android template as the starting point, with Dart application code and a Kotlin `MainActivity`. First prove that the untouched starter builds, then replace the counter example with a minimal DAYFLOW shell. This creates a useful baseline for distinguishing environment failures from application changes.

Create only the structure needed for the shell. Use GoRouter for the five approved destinations and Riverpod for dependency provisioning, beginning with the router. Keep native Android code limited to its generated entry point. Future feature logic will use feature-first presentation, domain, and data boundaries as each milestone introduces them.

M1 delivers environment documentation, an Android project, package configuration, local Git setup, baseline quality checks, and a navigable shell. The shell uses white surfaces, dark readable text, restrained lavender accents, and comfortable spacing. It does not establish the complete M2 design system.

M2 retains typography, final light/dark themes, reusable design tokens/components, official logo integration, and animated splash. M3 retains persistence and date utilities. Task management, calendar functionality, notes, reminders/settings, insights, and the companion follow M4–M9. No backend, account system, analytics, advertising, payments, or speculative dependencies are introduced.

## 3. Assumptions and risks before implementation

| Decision or risk | Proposed handling |
| --- | --- |
| Project location | Initialize directly in the current `dayflow` directory, avoiding a nested `dayflow/dayflow` project. Preserve the original brief unchanged. |
| Android application identity | Propose `com.dayflow.dayflow`, consistent with the example Kotlin path in the brief. This is a provisional engineering choice, not evidence of publisher ownership or Play Store availability. Confirm the intended publisher namespace before initialization. |
| Android support range | Start with supported SDK defaults from the selected Flutter template. Record resolved minimum, compile, and target SDK levels; review minimum-device coverage and later native dependencies before changing them. |
| Toolchain compatibility | Do not independently upgrade AGP, Kotlin, Gradle, or Java. Start with the stable Flutter template and verify their compatibility together. Java 17 being installed is not sufficient evidence of compatibility. |
| SDK installation paths | Choose a writable Flutter SDK path without spaces, outside the repository. The current workspace path contains spaces: quote commands and test it before considering relocation. Do not move the workspace preemptively. |
| Machine setup | SDK/IDE installations, persistent PATH changes, downloads, and writes outside the workspace may require execution approval. Handle that during implementation; none is required to review this plan. |
| Android licenses and device access | License review, USB authorization, and possibly emulator virtualization settings require user interaction. Report these as pending when necessary. |
| Git identity and remote | Use the user's intended name/email locally; do not invent them or change global identity. A hosted repository is not needed for M1; no remote or push is assumed. |
| Missing visual assets | Use a plain DAYFLOW text heading in M1. Document the future asset location, such as `assets/images/dayflow_logo.*`, without drawing a substitute logo. Keep generated launcher artwork explicitly temporary. |
| Dependency selection | Resolve stable packages against the installed SDK and review their constraints/changelogs. Commit `pubspec.lock`; package listings alone do not prove build compatibility. |
| Shared Drift/Kotlin database | Preserve the approved direction: one app-private SQLite database, Drift-owned schema/migrations, native operations behind a bridge. Do not add a competing database or a service process in M1. M3 must consider file-path/schema compatibility, and M9 must pass the shared-access proof of concept before full overlay work. |
| Specification detail for M3 | Notes are described as optionally associated with a date, but the example `Note.noteDate` is non-nullable. Resolve this when designing the schema, without changing M1 scope. |

## 4. Ordered execution plan

### Step 1 — Verify and establish the development environment

1. Check any user-provided custom SDK locations before installing duplicates.
2. Install the stable Flutter SDK from the official distribution in a suitable writable location. Add its `bin` directory to PATH and reopen the terminal/editor as needed. Use its bundled Dart SDK.
3. Install stable Android Studio and its required Android SDK components. Follow the current Flutter Android setup guide, then reconcile installed components with the generated template's requirements.
4. Select a compatible Gradle JDK and align Flutter, terminal, and Android Studio build configuration. Do not assume all three select the existing `JAVA_HOME` automatically.
5. Review Android SDK licenses interactively. Configure one Android emulator or physical device; verify hardware acceleration or the device's debugging authorization as applicable.
6. Capture the actual Flutter/Dart, Studio, Java, SDK, and device versions in the setup documentation. Exclude identifying device details and local personal paths from committed logs.

Planned diagnostics, after SDK setup:

```powershell
flutter --version
dart --version
java -version
flutter doctor --android-licenses
flutter doctor -v
flutter emulators
flutter devices
```

Gate: Flutter and the Android build toolchain are usable, licenses are accepted, and at least one Android run target is available. Unrelated Windows desktop or web tooling warnings do not block this Android-only milestone. If only device access is pending, build work can continue, but M1 cannot be declared complete.

### Step 2 — Establish local version control

1. Initialize Git on `main` in the current directory.
2. Add a baseline `.gitignore` before staging generated files. Exclude SDK installations, `.dart_tool/`, build outputs, Gradle caches, `android/local.properties`, personal IDE state, signing keys, and credentials. Preserve the generated Flutter ignore rules during initialization.
3. Configure repository-local author identity once supplied. Keep global Git settings unchanged.
4. Track the product brief and this plan. Make the baseline documentation commit once identity is available.
5. Review staged paths before each commit; do not stage machine caches or tools. No remote publication is part of this step.

Planned repository initialization:

```powershell
git init -b main
```

Gate: local repository exists with safe ignore rules; author identity is known before the first commit. Application work need not be blocked by a pending author identity.

### Step 3 — Generate the Android Flutter project

1. Confirm the application identity and check the installed CLI's `flutter create --help` options.
2. Generate the project in the existing directory, preserving both Markdown documents and any baseline ignore rules.
3. Generate Android only. Keep non-Android coupling out of Dart so future iOS work remains possible without adding unused platform projects now.
4. Resolve dependencies and retain the generated Flutter metadata, Gradle wrapper, and lockfile.
5. Run the generated starter's analysis, test, and debug APK build before modifying its application structure. Investigate failures at this gate rather than layering shell changes over them.

Proposed command, subject to the identity decision:

```powershell
flutter create --platforms=android --android-language=kotlin --org com.dayflow --project-name dayflow .
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Gate: the generated starter passes checks and produces a debug APK. Keep a reviewable checkpoint for this working baseline.

### Step 4 — Review Android configuration

1. Verify application ID, Gradle namespace, Kotlin package declaration, source directory, and manifest activity reference agree.
2. Set the user-visible application label to `DAYFLOW`.
3. Inspect the generated SDK levels, AGP/Kotlin configuration, Gradle wrapper, and Java/Kotlin compilation settings. Record the working combination rather than copying version numbers from the brief or older tutorials.
4. Retain the generated embedding, launch activity, launch theme, and supported system-bar behavior. Check safe areas and modern Android edge-to-edge layout on device.
5. Review manifests by build variant. Keep Flutter development connectivity where required for debugging; add no production overlay, notification, exact-alarm, foreground-service, accessibility, or unnecessary internet permissions.
6. Keep standard development signing. Production keystores and release distribution remain M10 work.

Gate: a debug APK builds with the chosen application identity and label; no native capability beyond M1 is enabled.

### Step 5 — Replace the sample with the initial app shell

1. Remove the sample counter UI and its obsolete test.
2. Add `flutter_riverpod` and `go_router` because this shell uses dependency provisioning and navigation. Use manual providers/routes, without code generation.
3. Keep `main.dart` small: initialize the Riverpod root and start `DayflowApp`. Put `MaterialApp.router` and minimal light styling in the app layer; provide and dispose the router through Riverpod.
4. Build a compact shell with the five approved bottom destinations in order: Home, Calendar, Notes, Insights, Settings. Default to Home. Derive the selected tab from the route rather than maintaining a duplicate tab index.
5. Home shows text branding and the approved tagline with a simple introductory placeholder. Other destinations show a quiet heading/placeholder. No fabricated tasks, statistics, account details, working-settings claims, or inactive task-creation controls.
6. Use a simple GoRouter shell. Top-level destination changes should not accumulate repeated tab entries; test Android back behavior against the chosen routing configuration.
7. Ensure navigation labels, touch targets, safe areas, and text scaling work on a small Android screen. Use temporary stock icons consistently until M2 establishes the final icon direction.

Proposed hand-written files, created only where needed:

```text
lib/
  main.dart
  app/
    app.dart
    router/app_router.dart
    shell/app_shell.dart
    shell/destination_placeholder.dart
    theme/app_theme.dart
  features/
    home/presentation/home_screen.dart
test/
  app_shell_test.dart
```

`app_theme.dart` contains only shell styling in M1. M2 develops the full theme/tokens. Future feature directories are created when their implementation begins. No empty repository, DAO, entity, use-case, database, native-service, or bridge layers are added now.

Gate: the shell runs offline, all five destinations navigate correctly, and no future feature is represented as implemented.

### Step 6 — Quality checks, device verification, and handoff

1. Retain `flutter_lints` and an explicit `analysis_options.yaml`; avoid introducing overlapping lint frameworks. Remove unused template dependencies.
2. Add focused widget coverage for launch, destination navigation/selection, and meaningful layout behavior under increased text size. Cover router/back behavior where useful; confirm Android system back on device. No mocking, persistence tests, or broad integration harness is needed yet.
3. Add `README.md` with prerequisites, the verified version matrix, local setup, run/build/test commands, application identity, current milestone, temporary assets, and known limitations.
4. Run the final checks after the shell replaces the starter:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

5. Run `flutter run -d <android-device-id>` with the actual discovered ID. Verify launch label, all five tabs, system back, text scaling, safe areas, background/resume, and relaunch. Save a shell screenshot when available.
6. Verify the APK artifact, normally `build/app/outputs/flutter-apk/app-debug.apk`. Record check outcomes and the tested Android version without committing build outputs.
7. Review the final diff and ignore behavior, commit the working shell with `pubspec.lock`, and finish with a clean working tree once all intended files are committed.

Gate: checks pass, an Android run has been observed, and setup is reproducible from the documentation. A successful APK build alone does not satisfy the device-run requirement.

## 5. M1 completion checklist

- [x] Stable Flutter and bundled Dart versions are recorded.
- [x] Android Studio, SDK, licenses, and compatible JDK/Gradle configuration are verified.
- [x] `flutter doctor -v` has no unresolved Android-blocking issue.
- [x] An emulator or physical Android device is detected and the shell runs on it.
- [x] Project is initialized at the current workspace root; the approved brief is unchanged.
- [x] Application ID/namespace/Kotlin package agree, and the launcher label is DAYFLOW.
- [x] Initial shell uses the approved light, restrained visual direction and five destinations.
- [x] Git repository, real local author identity, ignore rules, and baseline commit `4bf3f06` are established.
- [x] `pubspec.lock`, Gradle wrapper, source, tests, and setup documentation are committed in the M1 baseline.
- [x] Formatting, static analysis, focused tests, and final Android debug build pass.
- [x] Temporary assets, unresolved limitations, and verification evidence are documented.
- [x] M2–M10 functionality has not been introduced ahead of its milestone.

All M1 gates are satisfied. The initial assessment and ordered plan are retained as historical context; later milestone work is documented separately.

## 6. Official references checked for this plan

- Flutter SDK installation and installation-path guidance: [Install Flutter manually](https://docs.flutter.dev/install/manual).
- Android tooling, license review, and device verification: [Set up Android development](https://docs.flutter.dev/platform-integration/android/setup).
- Project and verification commands: [Flutter CLI reference](https://docs.flutter.dev/reference/flutter-cli).
- JDK selection and AGP compatibility: [Java versions in Android builds](https://developer.android.com/build/jdks).
- Android application identity and SDK configuration: [Build and release an Android app](https://docs.flutter.dev/deployment/android).
- Shell dependency metadata: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) and [go_router](https://pub.dev/packages/go_router).

Exact SDK, Gradle, Kotlin, and package versions are intentionally selected and recorded during implementation, after installation and dependency resolution. Current documentation is a starting point; the actual generated project and passing checks establish the working baseline.
