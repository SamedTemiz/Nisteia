import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/fasting_rules.dart';
import '../core/models.dart';
import 'settings.dart';

/// The fasting verdict for any date, in the user's chosen calendar mode.
/// Keyed by a date-only value (time is ignored by the engine anyway).
final fastingDayProvider = Provider.family<DayInfo, DateTime>((ref, date) {
  final calendar = ref.watch(settingsProvider.select((s) => s.calendar));
  return computeFastingDay(
    DateTime(date.year, date.month, date.day),
    calendar: calendar,
  );
});

/// Today and the next six days — for the Today screen's week strip.
final next7DaysProvider = Provider<List<DayInfo>>((ref) {
  final calendar = ref.watch(settingsProvider.select((s) => s.calendar));
  final today = DateTime.now();
  return List.generate(7, (i) {
    final d = DateTime(today.year, today.month, today.day + i);
    return computeFastingDay(d, calendar: calendar);
  });
});
