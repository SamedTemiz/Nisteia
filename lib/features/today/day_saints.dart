import '../../core/calendar_math.dart';
import '../../core/models.dart';
import '../../data/commemoration_names.dart';

/// The principal saint/feast names commemorated on [day], for the
/// "Saints of the Day" card. Uses the fixed (menaion) commemorations, matched
/// against the Julian date under the Old calendar so an Old-calendar user sees
/// the saints that fall on their civil day.
///
/// The moveable-cycle feast (Pascha, Palm Sunday, Pentecost…) is already named
/// by the engine's [DayInfo.titleKey]; this list adds the fixed-date saints.
List<String> saintsForDay(DayInfo day) {
  final Ymd fixed = day.calendar == Calendar.newCalendar
      ? (year: day.date.year, month: day.date.month, day: day.date.day)
      : julianYmdOfDate(day.date);
  return fixedCommemorationNames[fixed.month * 100 + fixed.day] ?? const [];
}

/// The Old-Style (Julian) calendar date for [date], used to show the "· N O.S."
/// secondary date line.
Ymd oldStyleDate(DateTime date) => julianYmdOfDate(date);
