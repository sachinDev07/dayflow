# DAYFLOW

Your day. Your pace. Your progress.

Android-first, offline-first personal productivity companion built with Flutter, Dart, and Kotlin.

## Product scope

[DAYFLOW_PROJECT_DETAILS.md](DAYFLOW_PROJECT_DETAILS.md) is the approved product specification. [M1_IMPLEMENTATION_PLAN.md](M1_IMPLEMENTATION_PLAN.md) records the initial assessment and ordered setup plan.

The M1 application shell is implemented and verified on Android. The remaining M1 housekeeping is the initial Git commit, pending the intended author name and email. The project uses Kotlin and application ID `com.dayflow.dayflow`.

The shell opens Home and provides Home, Calendar, Notes, Insights, and Settings navigation through GoRouter, with Riverpod provisioning and disposal of the router. Top-level tab changes replace the destination rather than accumulating history. Android Back returns to Home from another tab, then exits from Home. The UI uses restrained light styling and text branding; feature destinations are clearly marked as coming soon.

Later milestones cover the full design system, persistence, task management, calendar, notes, reminders, insights, and native floating companion. Those features are not implemented in this shell.

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

The generated starter passed analysis, its widget smoke test, and an Android debug build before replacement. The final shell then passed:

- Formatting verification: 9 Dart files, no changes required.
- `flutter analyze`: no issues found.
- `flutter test`: 2 tests covering destination navigation, selection, Back-to-Home behavior, and a 320×568 viewport with 200% text scaling.
- `flutter build apk --debug`: succeeded.
- Android 16/API 36 emulator checks: all five tabs, selected-tab accessibility state, Back-to-Home, Back-from-Home exit, background/resume, and fresh process relaunch.
- APK metadata: DAYFLOW label, `com.dayflow.dayflow`, minimum API 24, target API 36.

The local APK is `build/app/outputs/flutter-apk/app-debug.apk`; a verified Home screenshot is `build/m1-home.png`. Both are ignored build artifacts. The initial shell has no persistence or task functionality to test yet.

The resolved shell dependencies are Riverpod 3.5.0 and GoRouter 18.1.4. Flutter 3.50's generated template uses the `material_ui` package (resolved to 1.11.0); the shell retains that UI foundation. No code generators, databases, charts, notifications, or overlay packages were added.

## Version control

The local branch is `main`. No remote has been configured. No commits have been created because the intended author name and email have not been supplied. Do not invent an author identity or change global Git identity during setup.

The reviewed source baseline is staged. Git trust is limited to this exact workspace through a `safe.directory` entry because the repository was initially created by the sandbox account. The approved brief's original content and existing whitespace are preserved.

Generated files, local SDK paths, build outputs, caches, and signing credentials are excluded by `.gitignore`. The application lockfile and complete Gradle wrapper are included in the source baseline. No remote has been contacted for publication.

## Brand assets

The official logo and font files have not been supplied. M1 uses text branding and system typography. The generated Flutter launcher icon/native launch artwork remain temporary development assets. M2 will integrate the exact approved logo and typography through the future `assets/images/` and `assets/fonts/` locations; no replacement logo was drawn.

## Setup references

- [Flutter installation](https://docs.flutter.dev/install/manual)
- [Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup)
- [Android emulator acceleration](https://developer.android.com/studio/run/emulator-acceleration)
- [Android Gradle Plugin 9.3 compatibility](https://developer.android.com/build/releases/agp-9-3-0-release-notes)
