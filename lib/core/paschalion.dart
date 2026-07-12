/// Paschalion — computation of Orthodox Pascha (Easter) and the moveable
/// cycle that hangs off it.
///
/// All Orthodox churches — whether they keep the New (Revised Julian) or Old
/// (Julian) calendar for fixed feasts — compute Pascha with the **Julian**
/// Paschalion. So the *civil* date of Pascha is the same in both calendar
/// modes, and therefore so is the whole moveable cycle. Only the fixed feasts
/// differ between the two modes (handled in fasting_rules.dart).
///
/// Algorithm: Meeus's Julian-calendar Easter formula (public domain). It
/// yields the Julian-calendar date of Pascha; we convert to civil (Gregorian)
/// via the JDN so the result is correct in any century.
///
/// FLUTTER IMPORT FORBIDDEN in this file (architecture principle #2).
library;

import 'calendar_math.dart';

/// The Julian-calendar (year, month, day) of Pascha for [year], via Meeus.
Ymd paschaJulianYmd(int year) {
  final a = year % 4;
  final b = year % 7;
  final c = year % 19;
  final d = (19 * c + 15) % 30;
  final e = (2 * a + 4 * b - d + 34) % 7;
  final month = (d + e + 114) ~/ 31; // 3 = March, 4 = April (Julian)
  final day = (d + e + 114) % 31 + 1;
  return (year: year, month: month, day: day);
}

/// JDN of Pascha for [year].
int paschaJdn(int year) {
  final j = paschaJulianYmd(year);
  return julianToJdn(j.year, j.month, j.day);
}

/// Civil (Gregorian) [DateTime] of Pascha for [year].
///
/// e.g. `paschaGregorian(2026)` → 2026-04-12, `paschaGregorian(2027)` →
/// 2027-05-02.
DateTime paschaGregorian(int year) => dateOfJdn(paschaJdn(year));

/// Pascha-distance ("pdist"): signed number of days between [date] and Pascha
/// of the **same civil year**. Pascha itself is 0; Clean Monday is -48; Palm
/// Sunday -7; Pentecost +49.
///
/// Using the same-civil-year Pascha keeps the whole moveable window
/// (Publican & Pharisee at -70 in Feb through Apostles' Fast around +60 in
/// June) on one consistent reference. Fixed-cycle rules (Nov–Jan) never read
/// pdist, so the large +200 values that autumn dates produce are harmless.
int paschaDistance(DateTime date) => jdnOfDate(date) - paschaJdn(date.year);
