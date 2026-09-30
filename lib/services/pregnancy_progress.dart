/// Pregnancy age calculated from calendar dates, independent of their time parts.
///
/// [week] and [day] are completed weeks and remaining days (0-based). The app's
/// existing weekly content is numbered from 1, so [displayWeek] maps completed
/// age onto that content convention without changing the saved profile schema.
class PregnancyProgress {
  static const int pregnancyDurationDays = 280;

  final int totalDays;
  final int week;
  final int day;
  final int displayWeek;
  final int displayDay;

  const PregnancyProgress._({
    required this.totalDays,
    required this.week,
    required this.day,
    required this.displayWeek,
    required this.displayDay,
  });

  factory PregnancyProgress.fromLmpDate(
    DateTime lmpDate, {
    DateTime? currentDate,
  }) {
    final today = _utcCalendarDate(currentDate ?? DateTime.now());
    final lmp = _utcCalendarDate(lmpDate);
    final elapsedDays = today.difference(lmp).inDays;
    return PregnancyProgress.fromTotalDays(elapsedDays < 0 ? 0 : elapsedDays);
  }

  factory PregnancyProgress.fromDateStrings({
    String? lmpDate,
    String? dueDate,
    int fallbackWeek = 12,
    DateTime? currentDate,
  }) {
    final resolvedLmp = resolveLmpDate(lmpDate: lmpDate, dueDate: dueDate);
    if (resolvedLmp != null) {
      return PregnancyProgress.fromLmpDate(resolvedLmp,
          currentDate: currentDate);
    }

    // Old or incomplete records keep working without rewriting their stored week.
    final safeWeek = fallbackWeek.clamp(1, 42).toInt();
    return PregnancyProgress.fromTotalDays((safeWeek - 1) * 7);
  }

  factory PregnancyProgress.fromTotalDays(int days) {
    final totalDays = days < 0 ? 0 : days;
    final week = totalDays ~/ 7;
    final day = totalDays % 7;

    return PregnancyProgress._(
      totalDays: totalDays,
      week: week,
      day: day,
      displayWeek: (week + 1).clamp(1, 42).toInt(),
      displayDay: day + 1,
    );
  }

  /// Existing app data and the 1–40 week list use one-based week numbers.
  int get contentWeek => displayWeek.clamp(1, 40).toInt();

  /// Weekly content and trimester boundaries use the app's one-based week.
  int get trimester {
    if (displayWeek <= 13) return 1;
    if (displayWeek <= 27) return 2;
    return 3;
  }

  int get daysUntilDueDate => (pregnancyDurationDays - totalDays)
      .clamp(0, pregnancyDurationDays)
      .toInt();

  bool isWeekUnlocked(int candidateWeek,
      {Set<int> rewardUnlockedWeeks = const {}}) {
    return candidateWeek <= displayWeek ||
        rewardUnlockedWeeks.contains(candidateWeek);
  }

  /// Date-only addition avoids DST and hour-of-day changes affecting due dates.
  static DateTime addCalendarDays(DateTime date, int days) {
    final result = _utcCalendarDate(date).add(Duration(days: days));
    return DateTime(result.year, result.month, result.day);
  }

  static DateTime? resolveLmpDate({String? lmpDate, String? dueDate}) {
    final parsedLmp = parseCalendarDate(lmpDate);
    if (parsedLmp != null) return parsedLmp;

    final parsedDueDate = parseCalendarDate(dueDate);
    if (parsedDueDate == null) return null;
    return addCalendarDays(parsedDueDate, -pregnancyDurationDays);
  }

  static DateTime? parseCalendarDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim();
    if (normalized.length < 10) return null;

    final datePart = normalized.substring(0, 10);
    final parsed = DateTime.tryParse(datePart);
    if (parsed == null ||
        parsed.toIso8601String().substring(0, 10) != datePart) {
      return null;
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static DateTime _utcCalendarDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);
}
