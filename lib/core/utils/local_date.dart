/// A timezone-free Gregorian calendar date, stored as YYYY-MM-DD.
final class LocalDate implements Comparable<LocalDate> {
  factory LocalDate(int year, int month, int day) {
    final normalized = DateTime.utc(year, month, day);
    if (year < 1 ||
        year > 9999 ||
        normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw ArgumentError('Invalid calendar date: $year-$month-$day');
    }
    return LocalDate._(year, month, day);
  }

  const LocalDate._(this.year, this.month, this.day);

  factory LocalDate.parse(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      throw FormatException('Expected YYYY-MM-DD', value);
    }
    try {
      return LocalDate(
        int.parse(value.substring(0, 4)),
        int.parse(value.substring(5, 7)),
        int.parse(value.substring(8, 10)),
      );
    } on ArgumentError {
      throw FormatException('Invalid calendar date', value);
    }
  }

  /// Uses the date components in the caller's chosen timezone, never converts.
  factory LocalDate.fromDateTime(DateTime value) =>
      LocalDate(value.year, value.month, value.day);

  final int year;
  final int month;
  final int day;

  LocalDate addDays(int days) {
    final result = DateTime.utc(year, month, day).add(Duration(days: days));
    return LocalDate(result.year, result.month, result.day);
  }

  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDate other) => toString().compareTo(other.toString());
  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;
  @override
  int get hashCode => Object.hash(year, month, day);
}
