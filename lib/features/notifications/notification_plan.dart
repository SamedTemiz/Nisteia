import '../../core/fasting_rules.dart';
import '../../core/models.dart';
import '../seasons/season_math.dart';

/// Why a notification fires.
enum NotificationKind {
  /// The evening before a fast day that follows a non-fast day.
  fastEve,

  /// The evening before a major fasting season begins.
  seasonStart,
}

class PlannedNotification {
  const PlannedNotification({
    required this.kind,
    required this.when,
    required this.forDate,
    required this.level,
    required this.season,
  });

  /// When the notification should fire (local wall-clock).
  final DateTime when;

  /// The day the notification is about.
  final DateTime forDate;

  final NotificationKind kind;
  final FastLevel level;
  final FastSeason season;

  @override
  String toString() =>
      'PlannedNotification(${kind.name}, when=$when, for=$forDate, '
      '${level.name}, ${season.name})';
}

/// 19:00 the evening before [day].
DateTime _eveOf(DateTime day) => DateTime(day.year, day.month, day.day - 1, 19);

/// Pure planner: given a start date and the user's toggles, decide which local
/// notifications to schedule over the next [horizonDays]. Kept free of any
/// plugin so it is fully unit-testable; a thin platform service consumes it.
///
/// Rules (docs/screens.md §Onboarding / Notifications):
/// - **fastEve**: the evening before a fast day whose previous day was not a
///   fast — i.e. entering a fast (each ordinary Wed/Fri, and the first day of a
///   season). This avoids nagging every single day inside a long fast.
/// - **seasonStart**: the evening before a major fast begins. When a season
///   start and a fast-eve fall on the same evening, only the season start fires.
List<PlannedNotification> planNotifications(
  DateTime from, {
  required bool eveningReminder,
  required bool seasonAlerts,
  Calendar calendar = Calendar.newCalendar,
  int horizonDays = 30,
}) {
  final out = <PlannedNotification>[];
  final start = DateTime(from.year, from.month, from.day);

  DayInfo dayAt(int offset) => computeFastingDay(
        start.add(Duration(days: offset)),
        calendar: calendar,
      );

  for (var i = 1; i <= horizonDays; i++) {
    final today = dayAt(i);
    final prev = dayAt(i - 1);
    final date = DateTime(start.year, start.month, start.day + i);

    final seasonStarts =
        majorFasts.contains(today.season) && today.season != prev.season;
    final entersFast =
        today.level != FastLevel.fastFree && prev.level == FastLevel.fastFree;

    if (seasonAlerts && seasonStarts) {
      out.add(PlannedNotification(
        kind: NotificationKind.seasonStart,
        when: _eveOf(date),
        forDate: date,
        level: today.level,
        season: today.season,
      ));
      continue; // don't also send a plain fast-eve the same evening
    }

    if (eveningReminder && entersFast) {
      out.add(PlannedNotification(
        kind: NotificationKind.fastEve,
        when: _eveOf(date),
        forDate: date,
        level: today.level,
        season: today.season,
      ));
    }
  }

  return out;
}
