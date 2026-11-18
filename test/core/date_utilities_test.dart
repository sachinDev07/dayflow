import 'package:dayflow/core/utils/local_date.dart';
import 'package:dayflow/core/utils/reminder_instant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Calendar dates round trip without timezone conversion', () {
    for (final value in [
      '0001-01-01',
      '2024-02-29',
      '2026-11-18',
      '9999-12-31',
    ]) {
      expect(LocalDate.parse(value).toString(), value);
    }
    expect(
      LocalDate.fromDateTime(DateTime.utc(2026, 11, 18, 23)),
      LocalDate(2026, 11, 18),
    );
    expect(
      LocalDate.fromDateTime(DateTime(2026, 11, 18, 1)),
      LocalDate(2026, 11, 18),
    );
  });
  test('Invalid and ambiguous dates are rejected instead of normalized', () {
    for (final value in [
      '2025-02-29',
      '2026-02-30',
      '2026-13-01',
      '2026-00-10',
      '2026-01-00',
      '0000-01-01',
      '2026-1-01',
      '2026-01-01T00:00:00Z',
      ' 2026-01-01',
    ]) {
      expect(
        () => LocalDate.parse(value),
        throwsFormatException,
        reason: value,
      );
    }
    expect(() => LocalDate(2026, 2, 30), throwsArgumentError);
  });
  test('Date arithmetic is calendar based across leap years, DST, and year changes', () {
    expect(LocalDate(2024, 2, 28).addDays(1), LocalDate(2024, 2, 29));
    expect(LocalDate(2025, 2, 28).addDays(1), LocalDate(2025, 3, 1));
    expect(LocalDate(2026, 3, 8).addDays(1), LocalDate(2026, 3, 9));
    expect(LocalDate(2026, 12, 31).addDays(1), LocalDate(2027, 1, 1));
    expect(LocalDate(2026, 1, 1).addDays(-1), LocalDate(2025, 12, 31));
    expect(() => LocalDate(9999, 12, 31).addDays(1), throwsArgumentError);
    expect(LocalDate(2026, 1, 1).compareTo(LocalDate(2026, 1, 2)), isNegative);
  });
  test('Reminder offsets normalize to one UTC instant; timezone context does not move it', () {
    final india = ReminderInstant(
      DateTime.parse('2026-11-18T00:15:00+05:30'),
      timezone: 'Asia/Kolkata',
    );
    final utc = ReminderInstant(
      DateTime.parse('2026-11-17T18:45:00Z'),
      timezone: 'America/New_York',
    );
    expect(india.epochMilliseconds, utc.epochMilliseconds);
    expect(india.utc, DateTime.utc(2026, 11, 17, 18, 45));
    expect(india.utc.isUtc, isTrue);
    expect(
      () => ReminderInstant(DateTime.now(), timezone: ' '),
      throwsArgumentError,
    );
  });
}
