import '../../core/fasting_rules.dart';
import '../../core/models.dart';

/// The four major fasts we surface as seasons on the Seasons screen.
const majorFasts = {
  FastSeason.greatLent,
  FastSeason.apostlesFast,
  FastSeason.dormitionFast,
  FastSeason.nativityFast,
};

class ActiveFast {
  const ActiveFast(this.season, this.dayOfSeason, this.totalDays);
  final FastSeason season;
  final int dayOfSeason;
  final int totalDays;
}

class UpcomingFast {
  const UpcomingFast(this.season, this.start, this.daysUntil);
  final FastSeason season;
  final DateTime start;
  final int daysUntil;
}

class SeasonOverview {
  const SeasonOverview({required this.active, required this.next});
  final ActiveFast? active;
  final UpcomingFast? next;
}

DateTime _d(DateTime x) => DateTime(x.year, x.month, x.day);

/// Scan the engine around [from] to find the active fast (if any) and the next
/// upcoming major fast. Scanning keeps this in lock-step with the rule engine
/// rather than re-deriving season boundaries.
SeasonOverview computeSeasonOverview(
  DateTime from, {
  Calendar calendar = Calendar.newCalendar,
}) {
  final today = _d(from);
  FastSeason seasonOn(DateTime d) =>
      computeFastingDay(d, calendar: calendar).season;

  final todaySeason = seasonOn(today);

  ActiveFast? active;
  if (majorFasts.contains(todaySeason)) {
    var start = today;
    while (seasonOn(start.subtract(const Duration(days: 1))) == todaySeason) {
      start = start.subtract(const Duration(days: 1));
    }
    var end = today;
    while (seasonOn(end.add(const Duration(days: 1))) == todaySeason) {
      end = end.add(const Duration(days: 1));
    }
    final total = end.difference(start).inDays + 1;
    final dayOfSeason = today.difference(start).inDays + 1;
    active = ActiveFast(todaySeason, dayOfSeason, total);
  }

  // Next major fast that STARTS strictly after today (up to ~14 months out).
  UpcomingFast? next;
  var prevSeason = todaySeason;
  for (var i = 1; i <= 430; i++) {
    final d = today.add(Duration(days: i));
    final s = seasonOn(d);
    if (majorFasts.contains(s) && s != prevSeason) {
      next = UpcomingFast(s, d, i);
      break;
    }
    prevSeason = s;
  }

  return SeasonOverview(active: active, next: next);
}
