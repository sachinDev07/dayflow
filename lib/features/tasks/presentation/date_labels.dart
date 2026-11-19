import 'package:material_ui/material_ui.dart';

import '../../../core/utils/local_date.dart';

DateTime calendarDateTime(LocalDate date) =>
    DateTime(date.year, date.month, date.day);

String dateLabel(BuildContext context, LocalDate date) =>
    MaterialLocalizations.of(context).formatMediumDate(calendarDateTime(date));

String priorityLabel(String name) =>
    '${name.substring(0, 1).toUpperCase()}${name.substring(1)}';

Future<LocalDate?> pickTaskDate(BuildContext context, LocalDate initial) async {
  final value = await showDatePicker(
    context: context,
    initialDate: calendarDateTime(initial),
    firstDate: DateTime(1),
    lastDate: DateTime(9999, 12, 31),
    helpText: 'Choose a task date',
  );
  return value == null ? null : LocalDate.fromDateTime(value);
}
