/// Absolute reminder instant. Travel changes its displayed local time, not UTC.
/// IANA timezone context is informational until M7 defines reminder UI behavior.
final class ReminderInstant {
  ReminderInstant(DateTime instant, {String? timezone})
    : epochMilliseconds = instant.toUtc().millisecondsSinceEpoch,
      timezone = timezone?.trim() {
    if (this.timezone != null && this.timezone!.isEmpty) {
      throw ArgumentError.value(timezone, 'timezone', 'Cannot be blank');
    }
  }

  DateTime get utc =>
      DateTime.fromMillisecondsSinceEpoch(epochMilliseconds, isUtc: true);
  final int epochMilliseconds;
  final String? timezone;
}
