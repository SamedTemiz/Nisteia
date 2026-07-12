/// The fasting rule engine — the heart of the app.
///
/// Given a civil date and a calendar mode, it produces a [DayInfo] answering
/// "what can I eat today?". Rules are applied in strict priority order (see
/// docs/data-sources.md §2):
///
///   A. Fast-free weeks   — override everything.
///   B. Cheesefare week   — dairy allowed, no meat.
///   C. Fasting seasons   — Great Lent / Apostles' / Dormition / Nativity,
///                          with weekday and feast exceptions.
///   D. One-day fixed fasts (Theophany Eve, Beheading, Exaltation).
///   E. Weekly Wed/Fri fast.
///   F. Otherwise fast-free.
///
/// The logic (esp. the Apostles'/Nativity weekday exceptions, the Dec 20–24
/// forefeast tightening, and the weekend rules) is ported from the MIT-licensed
/// orthocal-python project (github.com/brianglass/orthocal-python), which
/// implements the OCA typikon. Our engine is validated day-by-day against
/// orthocal.info in test/validation/.
///
/// FLUTTER IMPORT FORBIDDEN in this file (architecture principle #2).
library;

import '../data/commemorations.dart';
import 'calendar_math.dart';
import 'models.dart';
import 'paschalion.dart';

/// Internal food-permission level shared by the season branches:
/// 0 = strict/xerophagy, 1 = wine & oil, 2 = fish, wine & oil.
typedef _Ex = int;

FastLevel _levelFromException(_Ex e) {
  switch (e) {
    case 2:
      return FastLevel.fishWineOil;
    case 1:
      return FastLevel.wineOil;
    default:
      return FastLevel.strict;
  }
}

/// Compute the fasting verdict for [date] under [calendar].
///
/// [date] is treated as a civil (Gregorian) calendar date; only its y/m/d are
/// used, never a wall-clock time or time zone.
///
/// Two layers: [_seasonalFastingDay] computes the season/weekday verdict, then
/// [_applyCommemorations] lifts the level when a saint's commemoration grants
/// fish or wine & oil (ported from orthocal's data + adjustment logic).
DayInfo computeFastingDay(
  DateTime date, {
  Calendar calendar = Calendar.newCalendar,
}) {
  final base = _seasonalFastingDay(date, calendar: calendar);
  return _applyCommemorations(date, calendar, base);
}

/// The seasonal/weekly verdict, before saint-commemoration relaxations.
DayInfo _seasonalFastingDay(
  DateTime date, {
  Calendar calendar = Calendar.newCalendar,
}) {
  final pdist = paschaDistance(date);
  final wd = date.weekday; // DateTime: Mon=1 .. Sun=7
  final bool isWeekend = wd == DateTime.saturday || wd == DateTime.sunday;

  // Fixed-cycle month/day. New calendar uses the civil date directly; Old
  // calendar matches fixed feasts against the Julian date the civil day
  // falls on (13 days earlier in y/m/d terms).
  final Ymd fixed = calendar == Calendar.newCalendar
      ? (year: date.year, month: date.month, day: date.day)
      : julianYmdOfDate(date);
  final int fm = fixed.month;
  final int fd = fixed.day;

  final int paschaYear = date.year;

  // pdist of a fixed feast in this calendar mode (for Apostles'-fast end and
  // Nativity/Theophany proximity checks). Routes through JDN so it's exact.
  int pdistOfFixed(int m, int d) {
    final int jdn = calendar == Calendar.newCalendar
        ? gregorianToJdn(paschaYear, m, d)
        : julianToJdn(paschaYear, m, d);
    return jdn - paschaJdn(paschaYear);
  }

  DayInfo build(
    FastLevel level,
    FastReason reason,
    FastSeason season,
    String titleKey,
  ) =>
      DayInfo(
        date: DateTime(date.year, date.month, date.day),
        calendar: calendar,
        paschaDistance: pdist,
        level: level,
        reason: reason,
        season: season,
        titleKey: titleKey,
      );

  // ------------------------------------------------------------------ Layer A
  // Fast-free weeks override everything, including Wednesday/Friday.
  if (pdist == 0) {
    return build(FastLevel.fastFree, FastReason.fastFreeWeek, FastSeason.none,
        'day.pascha');
  }
  if (pdist >= 1 && pdist <= 6) {
    // Bright Week (Pascha Monday .. Bright Saturday).
    return build(FastLevel.fastFree, FastReason.fastFreeWeek, FastSeason.none,
        'season.brightWeek');
  }
  if (pdist == 49) {
    return build(FastLevel.fastFree, FastReason.fastFreeWeek, FastSeason.none,
        'day.pentecost');
  }
  if (pdist >= 50 && pdist <= 56) {
    // Week after Pentecost (Trinity week), through All Saints Sunday.
    return build(FastLevel.fastFree, FastReason.fastFreeWeek, FastSeason.none,
        'season.pentecostWeek');
  }
  if (pdist >= -69 && pdist <= -64) {
    // Week after Publican & Pharisee Sunday (-70): no Wed/Fri fast.
    return build(FastLevel.fastFree, FastReason.fastFreeWeek, FastSeason.none,
        'season.fastFreeWeek');
  }
  if ((fm == 12 && fd >= 25) || (fm == 1 && fd <= 4)) {
    // Nativity (Dec 25) through the day before Theophany Eve (Jan 4).
    return build(FastLevel.fastFree, FastReason.fastFreeWeek, FastSeason.none,
        'season.nativityToTheophany');
  }

  // ------------------------------------------------------------------ Layer B
  // Cheesefare week: no meat, but dairy/eggs/fish all week (incl. Wed/Fri).
  if (pdist >= -55 && pdist <= -49) {
    return build(FastLevel.dairyAllowed, FastReason.season,
        FastSeason.cheesefareWeek, 'season.cheesefareWeek');
  }

  // ------------------------------------------------------------------ Layer C
  // Fasting seasons.

  // Great Lent: Clean Monday (-48) .. Holy Saturday (-1).
  if (pdist >= -48 && pdist <= -1) {
    _Ex e = isWeekend ? 1 : 0; // weekends wine&oil, weekdays strict
    FastReason reason = FastReason.season;
    String title = 'season.greatLent';

    // Specific Holy Week / Lenten days.
    if (pdist == -8) {
      // Lazarus Saturday: wine & oil (caviar in some traditions).
      if (e < 1) e = 1;
      title = 'day.lazarusSaturday';
    } else if (pdist == -7) {
      // Palm Sunday: fish permitted.
      e = 2;
      reason = FastReason.feast;
      title = 'day.palmSunday';
    } else if (pdist == -3) {
      // Holy Thursday: wine & oil.
      if (e < 1) e = 1;
      reason = FastReason.feast;
      title = 'day.holyThursday';
    } else if (pdist == -2) {
      // Great & Holy Friday: strict.
      e = 0;
      reason = FastReason.feast;
      title = 'day.holyFriday';
    } else if (pdist == -1) {
      // Holy Saturday: wine & oil.
      if (e < 1) e = 1;
      title = 'day.holySaturday';
    }

    // Annunciation (fixed Mar 25) falling within Lent: fish permitted.
    if (fm == 3 && fd == 25) {
      e = 2;
      reason = FastReason.feast;
      title = 'day.annunciation';
    }

    return build(_levelFromException(e), reason, FastSeason.greatLent, title);
  }

  // Apostles' Fast: Monday after All Saints (pdist 57) .. Ss. Peter & Paul
  // (fixed Jun 29). Length varies with Pascha; can be zero when Pascha is late.
  final bool inApostles = pdist > 56 && pdist < pdistOfFixed(6, 29);

  // Nativity Fast: Nov 15 .. Dec 24 (fixed). Dec 25+ handled by Layer A.
  final bool inNativity =
      (fm == 11 && fd >= 15) || (fm == 12 && fd >= 1 && fd <= 24);

  if (inApostles || inNativity) {
    // Base exception by weekday (orthocal typikon):
    //   Mon/Wed/Fri strict, Tue/Thu wine&oil, Sat/Sun fish.
    _Ex e;
    switch (wd) {
      case DateTime.tuesday:
      case DateTime.thursday:
        e = 1;
      case DateTime.saturday:
      case DateTime.sunday:
        e = 2;
      default: // Mon, Wed, Fri
        e = 0;
    }
    FastReason reason = FastReason.season;
    final FastSeason season =
        inNativity ? FastSeason.nativityFast : FastSeason.apostlesFast;
    String title = inNativity ? 'season.nativityFast' : 'season.apostlesFast';

    // Entry of the Theotokos (Nov 21): fish permitted within the Nativity fast.
    if (inNativity && fm == 11 && fd == 21) {
      e = 2;
      reason = FastReason.feast;
      title = 'day.entryOfTheotokos';
    }

    // Forefeast of the Nativity (Dec 20–24): no fish even on weekends.
    if (inNativity && fm == 12 && fd >= 20 && fd <= 24) {
      if (e > 1) e = 1;
      if (fd == 24) {
        // Nativity Eve (Paramony): strict on weekdays, wine&oil on weekends.
        title = 'day.nativityEve';
        reason = FastReason.season;
        if (!isWeekend) e = 0;
      }
    }

    return build(_levelFromException(e), reason, season, title);
  }

  // Dormition Fast: Aug 1–14 (fixed). Stricter than Apostles'/Nativity —
  // fish only on Transfiguration; weekends get wine & oil, weekdays strict.
  if (fm == 8 && fd >= 1 && fd <= 14) {
    _Ex e = isWeekend ? 1 : 0;
    FastReason reason = FastReason.season;
    String title = 'season.dormitionFast';
    if (fm == 8 && fd == 6) {
      // Transfiguration: fish permitted.
      e = 2;
      reason = FastReason.feast;
      title = 'day.transfiguration';
    }
    return build(
        _levelFromException(e), reason, FastSeason.dormitionFast, title);
  }

  // ------------------------------------------------------------------ Layer D
  // One-day fixed fasts. Per the OCA typikon (as implemented by orthocal), these
  // are strict fast days on which **wine and oil are permitted** — not full
  // xerophagy. Theophany Eve (Paramony) remains strict.
  if (fm == 1 && fd == 5) {
    return build(FastLevel.strict, FastReason.feast, FastSeason.none,
        'day.theophanyEve');
  }
  if (fm == 8 && fd == 29) {
    return build(FastLevel.wineOil, FastReason.feast, FastSeason.none,
        'day.beheadingOfJohn');
  }
  if (fm == 9 && fd == 14) {
    return build(FastLevel.wineOil, FastReason.feast, FastSeason.none,
        'day.exaltationOfCross');
  }

  // ------------------------------------------------------------------ Layer E
  // Weekly Wednesday/Friday fast (outside every season and fast-free week).
  if (wd == DateTime.wednesday || wd == DateTime.friday) {
    // Pentecostarion (Thomas Sunday .. day before Pentecost, pdist 7..48):
    // Wed & Fri remain fast days, but with wine & oil allowed — the Paschal
    // season lightens the weekly fast. Outside it, xerophagy (strict).
    if (pdist >= 7 && pdist <= 48) {
      return build(FastLevel.wineOil, FastReason.weekday, FastSeason.none,
          'day.wednesdayFriday');
    }
    return build(FastLevel.strict, FastReason.weekday, FastSeason.none,
        'day.wednesdayFriday');
  }

  // ------------------------------------------------------------------ Layer F
  return build(
      FastLevel.fastFree, FastReason.none, FastSeason.none, 'fastFree');
}

/// Lift [base] when a fixed-date or moveable commemoration grants fish or
/// wine & oil that the seasonal layer didn't. Faithful port of orthocal's
/// `Day._apply_fasting_adjustments`: the raw exception is read from the ported
/// [fixedCommemorations]/[movableCommemorations] tables, then capped by the
/// season and weekday (fish is downgraded for minor feasts in Lent, on Wed/Fri
/// inside the Apostles'/Nativity fasts below polyeleos rank, and during the
/// Nativity forefeast). The result can only make a day *more* permissive than
/// the seasonal verdict, never stricter — so the season layer stays the floor.
DayInfo _applyCommemorations(DateTime date, Calendar calendar, DayInfo base) {
  final int pdist = base.paschaDistance;
  final int wd = date.weekday;

  final Ymd fixed = calendar == Calendar.newCalendar
      ? (year: date.year, month: date.month, day: date.day)
      : julianYmdOfDate(date);

  // Raw exception = max over the fixed-date and moveable commemorations, keeping
  // the feast_level that goes with the winning exception.
  int fe = 0;
  int feastLevel = -1;
  final List<int>? fx = fixedCommemorations[fixed.month * 100 + fixed.day];
  if (fx != null) {
    fe = fx[0];
    feastLevel = fx[1];
  }
  final List<int>? mv = movableCommemorations[pdist];
  if (mv != null && (mv[0] > fe || (mv[0] == fe && mv[1] > feastLevel))) {
    fe = mv[0];
    feastLevel = mv[1];
  }
  if (fe == 0) return base; // no commemoration override today

  // A "fast free" commemoration (code 11) lifts everything, before any of the
  // season/weekday caps below can touch it (orthocal returns early here too).
  if (fe == 11) {
    if (base.level == FastLevel.fastFree) return base;
    return DayInfo(
      date: base.date,
      calendar: base.calendar,
      paschaDistance: base.paschaDistance,
      level: FastLevel.fastFree,
      reason: FastReason.feast,
      season: base.season,
      titleKey: base.titleKey,
    );
  }

  // orthocal `_apply_fasting_adjustments` (fasting-relevant branches only).
  switch (base.season) {
    case FastSeason.greatLent:
      if (fe == 2) fe = 1; // fish removed for minor feasts in Lent
    case FastSeason.apostlesFast:
    case FastSeason.nativityFast:
      switch (wd) {
        case DateTime.tuesday:
        case DateTime.thursday:
          if (fe == 0) fe = 1;
        case DateTime.wednesday:
        case DateTime.friday:
          // Fish only survives Wed/Fri for polyeleos-and-above feasts.
          if (feastLevel < 4 && fe > 1) fe = 1;
        case DateTime.saturday:
        case DateTime.sunday:
          fe = 2;
      }
      // Nativity forefeast (Dec 20–23, i.e. strictly before Nativity Eve): no
      // fish even for feasts. Dec 24 itself is excluded (orthocal uses a strict
      // `pdist < nativity-1`), and is governed by the Eve rule below.
      if (base.season == FastSeason.nativityFast &&
          fixed.month == 12 &&
          fixed.day >= 20 &&
          fixed.day <= 23 &&
          fe > 1) {
        fe = 1;
      }
    case FastSeason.none:
    case FastSeason.dormitionFast:
    case FastSeason.cheesefareWeek:
      break;
  }

  // Nativity Eve (Dec 24) and Theophany Eve (Jan 5) falling on a weekend are
  // wine-and-oil days (orthocal's final `_apply_fasting_adjustments` rule).
  final bool isWeekend = wd == DateTime.saturday || wd == DateTime.sunday;
  if (isWeekend &&
      ((fixed.month == 12 && fixed.day == 24) ||
          (fixed.month == 1 && fixed.day == 5))) {
    fe = 1;
  }

  final FastLevel grant = _levelFromCommemoration(fe);
  // Levels order by strictness (higher index = stricter); keep the more
  // permissive of the seasonal floor and the commemoration grant.
  if (grant.index >= base.level.index) return base;

  return DayInfo(
    date: base.date,
    calendar: base.calendar,
    paschaDistance: base.paschaDistance,
    level: grant,
    reason: FastReason.feast,
    season: base.season,
    titleKey: base.titleKey,
  );
}

/// Map an orthocal `fast_exception` code to a [FastLevel]. Codes 2 & 4 permit
/// fish; 1/3/5/6/8 permit wine & oil (6 adds caviar, which we bucket with wine
/// & oil as we model no separate caviar level); 7 is the cheesefare "Meat Fast"
/// (dairy allowed). Codes 9 (strict) and 10 ("no overrides") grant nothing, so
/// the seasonal floor stands. Code 11 (fast free) is handled before this call.
FastLevel _levelFromCommemoration(int fe) {
  switch (fe) {
    case 2:
    case 4:
      return FastLevel.fishWineOil;
    case 1:
    case 3:
    case 5:
    case 6:
    case 8:
      return FastLevel.wineOil;
    case 7:
      return FastLevel.dairyAllowed;
    default:
      return FastLevel.strict;
  }
}
