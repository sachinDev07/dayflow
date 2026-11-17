# DAYFLOW M2 design system

Started 17 November 2026 (Asia/Calcutta). M1's committed baseline is `4bf3f06`.

## Design source and interpretation

The user supplied `design-preferences/` as the approved visual reference. The product brief remains the source of truth for functionality and milestone boundaries. The screen images guide layout, typography, icon treatment, shapes, and visual hierarchy; their sample dates, tasks, avatars, and percentages are not application data.

| Reference | Implementation guidance | Functional milestone |
| --- | --- | --- |
| `00_dayflow_ui_screens_overview.png` | Overall visual context; specific screen boards take precedence | Across milestones |
| `01_dayflow_home_dashboard_design.png` | Compact brand header, greeting, typography-led hierarchy, modest progress, divided task rows, purple bottom navigation | Home/task behavior in M4 |
| `02_dayflow_add_edit_task_flow_v4.png` | Latest task-flow revision: compact sheet, Today/Tomorrow/Pick Date, expandable options, rounded inputs, pill action | Task form in M4 |
| Older task-flow images | Historical alternatives; keep as references without mixing conflicting layouts into v4 | None independently |
| `03_dayflow_calendar_screen_design.png` | Calm monthly layout, purple selected day, small indicators, task rows below | M5 |
| `04_dayflow_notes_screen_design.png` | Notebook-like list, quiet categories, simple sheet/editor layout | M6 |
| `05_dayflow_insights_screen_design.png` | Restrained purple charts, real-data highlights, compact summaries | M8 |
| `06_dayflow_settings_screen_design.png` | Rounded grouped settings, light/dark appearance, optional companion | M7/M9 |
| `07_dayflow_floating_companion_design.png` | Bubble, quick actions, expanded card, compact mode | M9, after shared-database proof of concept |

The mountain backgrounds, decorative poster gradients, device frames, and surrounding feature captions are presentation material outside the application viewport. They are not app backgrounds. The supplied logo's own artwork is retained as approved branding.

The settings boards show account/sync and a focus timer, and the insights board includes a Year filter. These do not add MVP requirements. Backup/sync, account flows, focus timers, yearly analytics, reminders, and overlay permissions are not implemented in M2. Placeholder destinations remain explicitly marked as coming soon. No task entry or fabricated progress is added before persistence and task milestones.

## Architecture and scope

- Keep the existing Riverpod/GoRouter app structure and five routes.
- Centralize semantic colors in `DayflowColors`, a theme extension supporting interpolation between themes.
- Define spacing, radius, and duration constants in `lib/app/theme/design_tokens.dart`.
- Build both Material themes from the same design tokens and bundled typography.
- Add reusable brand/logo, action, input, surface, empty-state, keyboard-aware sheet, and launch-reveal widgets in `lib/core/widgets/`.
- Restyle the shell and placeholders using those components. Header settings access works; no nonfunctional reminder bell or fictional profile photo is added.
- Provide `tool/design_preview.dart` as an alternate developer entry point for checking components and both themes. It is absent from product routes.
- Leave appearance persistence and the user-facing theme controls for M7. `DayflowApp(themeMode: ...)` supports explicit light, dark, or system selection; the product default remains light.

## Tokens and accessibility

The base spacing is 4 logical pixels. Common rhythm uses 8, 16, 24, and 32; screen padding is 20. Inputs use radius 12, surfaces 16, sheets 24, and primary buttons a pill radius. Touch targets are at least 48 pixels, with primary actions at least 52 pixels high.

The palette retains the brief's white and near-black canvases, `#A98AFF` lavender, `#7C5CFF` purple, and quiet dividers. Filled action gradients are limited to primary actions; they are darker than the poster buttons to keep white labels readable. Secondary text also uses a slightly darker light-theme value. The tests require a contrast ratio of at least 4.5 for normal text on the supported surfaces and for both ends of the primary-action gradient. Color alone does not establish tab selection: labels and selected semantics remain present.

Plus Jakarta Sans uses 14px secondary copy, 16px body/task-direction text, 20px brand/section type, and 24–26px page headings. Titles wrap as needed. At very large text sizes the header wordmark may truncate visually while its full DAYFLOW semantic label remains available. Content scrolls; navigation keeps the same five labels.

Motion is normally 200ms for interactions and 220ms for the launch reveal. Reduced-motion preferences skip the launch fade and sheet/navigation transitions. The launch fade does not create a loading route, hold Android's splash, block input, or introduce an artificial startup delay.

## Brand asset and launch

The user identified `design-preferences/dayflow_app_icon.png` as the approved standalone logo. It is a 1536×1024 PNG with transparency and glow surrounding the central icon. It is copied unchanged to:

- `assets/images/dayflow_app_icon.png` for Flutter.
- `android/app/src/main/res/drawable-nodpi/dayflow_app_icon.png` for native launch.

All three files have SHA-256 `C4C872AEB061C5D7B28A0E9EA525293A66DE85C6E73AFCF2275FC05F0CD4CAE1`.

`DayflowLogo` presents the central icon in a rounded square viewport at runtime. It does not generate, redraw, retouch, or modify the source PNG. The native launch drawable presents the original artwork at its 3:2 aspect ratio; Android 12+ has explicit SplashScreen theme attributes. The normal launch background matches the light product default, including when the device itself uses dark mode.

Raster artwork does not contain separately animatable stroke paths. M2 uses a restrained fade of the exact logo/wordmark on the ready screen. An exact circle-then-checkmark draw can replace this if the approved vector paths are supplied. No approximate vector logo is invented. Launcher icon and store asset production remain M10; the generated launcher icon is still a development placeholder.

## Font provenance

Plus Jakarta Sans normal and italic variable fonts are bundled locally. The app does not fetch fonts over the network. Source: the official [Google Fonts repository](https://github.com/google/fonts/tree/main/ofl/plusjakartasans), downloaded 17 November 2026. The SIL Open Font License and copyright notice are included in `assets/fonts/OFL.txt`.

| File | SHA-256 |
| --- | --- |
| `PlusJakartaSans-Variable.ttf` | `89B3FB38AA0D275D7A731D0D817A4F1622B316B4D7FBDEDCF02EE9099FF68BC8` |
| `PlusJakartaSans-Italic-Variable.ttf` | `9529EB888668B6A3C6DD75B6341A2FC5263FB6C9E788822E6117C29DD9E8B115` |

Lucide Icons Flutter 4.0.3 supplies consistent line icons, as permitted by the brief. Flutter's existing `material_ui` foundation is retained. No runtime font service, animation package, database, notifications, analytics, or native overlay service is introduced.

## Review and verification

The first expanded test run found a right overflow in the header at 320×568 with 200% text scale; the wordmark was constrained while preserving its semantic label. Final verification completed on 18 November 2026: formatting and analysis passed, all 8 tests passed, and both the main and component-preview Android APKs built successfully.

On the Android 16/API 36 emulator, the light/dark component screens and the keyboard-aware sheet were visually reviewed. The sheet action remained above the keyboard and closed successfully. The final main APK was restored, its Home screen reviewed, all five destinations exercised, and Back-to-Home behavior verified. Checked Flutter logs contained no layout exceptions. The original brief's SHA-256 remains `3680B011EC078B0836FD7A55FCAD480938C689B197D2B0A3A1EC5642A122E5EC`.

The host showed memory pressure and emulator System UI cold-start timeouts. Compilation and emulator checks were serialized, with Gradle stopped before device verification. This is a functional/emulator check, not a production startup-performance or physical-device certification. Native resources compile for the project's minimum API 24; runtime checks were performed only on API 36.

Screenshots are in ignored build output: `build/m2-home.png`, `build/m2-preview-light.png`, `build/m2-preview-dark.png`, and `build/m2-preview-sheet.png`. The main APK is `build/app/outputs/flutter-apk/app-debug.apk`.

M2's design foundation is implemented. The raster logo uses fade animation; exact stroke drawing remains dependent on approved vector paths. Production launcher/store artwork remains M10, and feature behavior follows M3–M9.

Relevant checks include both themes' contrast, bundled logo/font loading, light-default versus system-theme behavior, reduced-motion launch, input validation and sheet reachability, disabled actions, existing five-destination navigation, large-text layout, Android build, and on-device visual/launch checks.

The preview is separate from the application:

```powershell
flutter run -t tool/design_preview.dart -d <android-device-id>
```

Its theme toggle and sample sheet affect only the preview process. They do not save tasks, change persistent preferences, or imply feature completion.
