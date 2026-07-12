/// Pure-Dart calendar arithmetic: conversions between civil dates and the
/// Julian Day Number (JDN), for both the Gregorian (New/Revised Julian) and
/// Julian (Old) calendars.
///
/// The JDN is a calendar-independent integer count of days. Routing every
/// date through the JDN lets us compare a Gregorian civil date against a
/// fixed feast expressed on the Julian calendar without ever hard-coding the
/// "+13 days" offset — the offset falls out of the math and stays correct
/// across century boundaries.
///
/// FLUTTER IMPORT FORBIDDEN in this file (architecture principle #2).
library;

/// A plain year/month/day triple. `month` is 1..12, `day` is 1..31.
typedef Ymd = ({int year, int month, int day});

/// Julian Day Number for a date on the **Gregorian** (proleptic) calendar.
///
/// Uses the standard Fliegel–Van Flandern algorithm. Returns the JDN of the
/// day (noon-based astronomical JDN, integer).
int gregorianToJdn(int year, int month, int day) {
  final a = (14 - month) ~/ 12;
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  return day +
      (153 * m + 2) ~/ 5 +
      365 * y +
      y ~/ 4 -
      y ~/ 100 +
      y ~/ 400 -
      32045;
}

/// Julian Day Number for a date on the **Julian** (proleptic) calendar.
int julianToJdn(int year, int month, int day) {
  final a = (14 - month) ~/ 12;
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  return day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - 32083;
}

/// Convert a JDN back to a **Gregorian** calendar date.
Ymd jdnToGregorian(int jdn) {
  final a = jdn + 32044;
  final b = (4 * a + 3) ~/ 146097;
  final c = a - (146097 * b) ~/ 4;
  final d = (4 * c + 3) ~/ 1461;
  final e = c - (1461 * d) ~/ 4;
  final m = (5 * e + 2) ~/ 153;
  final day = e - (153 * m + 2) ~/ 5 + 1;
  final month = m + 3 - 12 * (m ~/ 10);
  final year = 100 * b + d - 4800 + m ~/ 10;
  return (year: year, month: month, day: day);
}

/// Convert a JDN back to a **Julian** calendar date.
Ymd jdnToJulian(int jdn) {
  final c = jdn + 32082;
  final d = (4 * c + 3) ~/ 1461;
  final e = c - (1461 * d) ~/ 4;
  final m = (5 * e + 2) ~/ 153;
  final day = e - (153 * m + 2) ~/ 5 + 1;
  final month = m + 3 - 12 * (m ~/ 10);
  final year = d - 4800 + m ~/ 10;
  return (year: year, month: month, day: day);
}

// ---------------------------------------------------------------------------
// DateTime bridges. All app-facing DateTimes are civil (Gregorian) dates in
// UTC-agnostic terms; we only ever use the y/m/d fields, never a wall clock.
// ---------------------------------------------------------------------------

/// JDN of a civil [DateTime] (interpreted on the Gregorian calendar).
int jdnOfDate(DateTime date) => gregorianToJdn(date.year, date.month, date.day);

/// Civil (Gregorian) [DateTime] at midnight for a JDN.
DateTime dateOfJdn(int jdn) {
  final g = jdnToGregorian(jdn);
  return DateTime(g.year, g.month, g.day);
}

/// The Julian-calendar y/m/d that a civil (Gregorian) [DateTime] falls on.
///
/// In Old-calendar mode a fixed feast keyed to a Julian date (e.g. Nativity =
/// Julian Dec 25) is matched by comparing against this.
Ymd julianYmdOfDate(DateTime date) => jdnToJulian(jdnOfDate(date));
