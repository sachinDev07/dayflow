import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'app/licenses.dart';

void main() {
  registerFontLicenses();
  runApp(const ProviderScope(child: DayflowApp()));
}
