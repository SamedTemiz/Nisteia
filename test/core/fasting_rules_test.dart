import 'package:flutter_test/flutter_test.dart';
import 'package:nisteia/core/fasting_rules.dart';
import 'package:nisteia/core/models.dart';

void main() {
  // All dates below are for liturgical year 2026 (Pascha = Sun 12 Apr 2026),
  // New calendar unless a test says otherwise.
  DayInfo day(int y, int m, int d, [Calendar cal = Calendar.newCalendar]) =>
      computeFastingDay(DateTime(y, m, d), calendar: cal);

  group('fast-free weeks (override everything)', () {
    test('Pascha is fast-free', () {
      final r = day(2026, 4, 12);
      expect(r.level, FastLevel.fastFree);
      expect(r.reason, FastReason.fastFreeWeek);
      expect(r.titleKey, 'day.pascha');
    });

    test('Bright Week Wednesday is fast-free (not a fast day)', () {
      final r = day(2026, 4, 15); // Bright Wednesday
      expect(r.date.weekday, DateTime.wednesday);
      expect(r.level, FastLevel.fastFree);
      expect(r.season, FastSeason.none);
    });

    test('Pentecost is fast-free', () {
      final r = day(2026, 5, 31);
      expect(r.level, FastLevel.fastFree);
      expect(r.titleKey, 'day.pentecost');
    });

    test('Nativity (Dec 25) through Jan 4 is fast-free', () {
      expect(day(2026, 12, 25).level, FastLevel.fastFree);
      expect(day(2026, 12, 31).level, FastLevel.fastFree);
      expect(day(2027, 1, 4).level, FastLevel.fastFree);
      expect(day(2026, 12, 25).titleKey, 'season.nativityToTheophany');
    });
  });

  group('Cheesefare week (dairy allowed)', () {
    test('Cheesefare Wednesday allows dairy, not meat', () {
      final r = day(2026, 2, 18); // pdist -53, Wednesday
      expect(r.date.weekday, DateTime.wednesday);
      expect(r.level, FastLevel.dairyAllowed);
      expect(r.season, FastSeason.cheesefareWeek);
      expect(r.allowed.dairy, isTrue);
      expect(r.allowed.meat, isFalse);
    });
  });

  group('Great Lent', () {
    test('Clean Monday is strict', () {
      final r = day(2026, 2, 23);
      expect(r.paschaDistance, -48);
      expect(r.level, FastLevel.strict);
      expect(r.season, FastSeason.greatLent);
      expect(r.allowed.oil, isFalse);
    });

    test('Lenten weekday (Wed) is strict', () {
      final r = day(2026, 2, 25);
      expect(r.date.weekday, DateTime.wednesday);
      expect(r.level, FastLevel.strict);
    });

    test('Lenten Saturday allows wine & oil', () {
      final r = day(2026, 2, 28);
      expect(r.date.weekday, DateTime.saturday);
      expect(r.level, FastLevel.wineOil);
      expect(r.allowed.oil, isTrue);
      expect(r.allowed.fish, isFalse);
    });

    test('Annunciation in Lent allows fish (feast override on a weekday)', () {
      final r = day(2026, 3, 25);
      expect(r.date.weekday, DateTime.wednesday);
      expect(r.level, FastLevel.fishWineOil);
      expect(r.reason, FastReason.feast);
      expect(r.titleKey, 'day.annunciation');
    });

    test('Palm Sunday allows fish', () {
      final r = day(2026, 4, 5);
      expect(r.paschaDistance, -7);
      expect(r.level, FastLevel.fishWineOil);
      expect(r.titleKey, 'day.palmSunday');
    });

    test('Great & Holy Friday is strict', () {
      final r = day(2026, 4, 10);
      expect(r.paschaDistance, -2);
      expect(r.level, FastLevel.strict);
      expect(r.titleKey, 'day.holyFriday');
    });
  });

  group('Nativity Fast', () {
    test('ordinary Monday is strict', () {
      final r = day(2026, 11, 23); // no commemoration
      expect(r.date.weekday, DateTime.monday);
      expect(r.level, FastLevel.strict);
      expect(r.season, FastSeason.nativityFast);
    });

    test('Apostle Matthew (Nov 16) allows fish even on a Monday', () {
      // Polyeleos-rank feast (feast_level 6): fish survives the weekday fast.
      final r = day(2026, 11, 16);
      expect(r.date.weekday, DateTime.monday);
      expect(r.level, FastLevel.fishWineOil);
      expect(r.reason, FastReason.feast);
      expect(r.season, FastSeason.nativityFast);
    });

    test('Tuesday allows wine & oil', () {
      final r = day(2026, 11, 17);
      expect(r.date.weekday, DateTime.tuesday);
      expect(r.level, FastLevel.wineOil);
    });

    test('Saturday allows fish', () {
      final r = day(2026, 11, 21); // also Entry of the Theotokos
      expect(r.date.weekday, DateTime.saturday);
      expect(r.level, FastLevel.fishWineOil);
    });

    test('Nativity Eve (Dec 24) is strict on a weekday', () {
      final r = day(2026, 12, 24);
      expect(r.date.weekday, DateTime.thursday);
      expect(r.level, FastLevel.strict);
      expect(r.titleKey, 'day.nativityEve');
    });

    test('Dec 20–24 forefeast disallows fish even on a weekend', () {
      // 19 Dec 2026 is Saturday → fish; 20 Dec (Sun) is inside forefeast → capped.
      final sat = day(2026, 12, 19);
      expect(sat.date.weekday, DateTime.saturday);
      expect(sat.level, FastLevel.fishWineOil);
      final sun = day(2026, 12, 20);
      expect(sun.date.weekday, DateTime.sunday);
      expect(sun.level, FastLevel.wineOil); // fish removed by forefeast rule
    });
  });

  group('Dormition Fast', () {
    test('weekday is strict', () {
      final r = day(2026, 8, 3); // Monday
      expect(r.date.weekday, DateTime.monday);
      expect(r.level, FastLevel.strict);
      expect(r.season, FastSeason.dormitionFast);
    });

    test('Transfiguration (Aug 6) allows fish', () {
      final r = day(2026, 8, 6);
      expect(r.level, FastLevel.fishWineOil);
      expect(r.titleKey, 'day.transfiguration');
    });

    test('weekend allows wine & oil but not fish', () {
      final r = day(2026, 8, 8); // Saturday
      expect(r.date.weekday, DateTime.saturday);
      expect(r.level, FastLevel.wineOil);
    });
  });

  group('one-day fixed fasts', () {
    test('Exaltation of the Cross (Sep 14) allows wine & oil (OCA typikon)',
        () {
      final r = day(2026, 9, 14); // Monday
      expect(r.date.weekday, DateTime.monday);
      expect(r.level, FastLevel.wineOil);
      expect(r.titleKey, 'day.exaltationOfCross');
    });

    test('Beheading of John the Baptist (Aug 29) allows wine & oil', () {
      expect(day(2026, 8, 29).titleKey, 'day.beheadingOfJohn');
      expect(day(2026, 8, 29).level, FastLevel.wineOil);
    });
  });

  group('ordinary weekly rhythm', () {
    test('ordinary Wednesday is a strict fast', () {
      final r = day(2026, 10, 7);
      expect(r.date.weekday, DateTime.wednesday);
      expect(r.level, FastLevel.strict);
      expect(r.reason, FastReason.weekday);
      expect(r.season, FastSeason.none);
    });

    test('ordinary Thursday is fast-free', () {
      final r = day(2026, 10, 8);
      expect(r.date.weekday, DateTime.thursday);
      expect(r.level, FastLevel.fastFree);
      expect(r.reason, FastReason.none);
    });
  });

  group('Old vs New calendar', () {
    test('New calendar: civil Dec 25 is fast-free (Nativity)', () {
      expect(day(2026, 12, 25).level, FastLevel.fastFree);
    });

    test('Old calendar: civil Dec 25 is still the Nativity fast', () {
      // Julian Dec 12 → inside Nativity fast; civil Dec 25 2026 is a Friday.
      final r = day(2026, 12, 25, Calendar.oldCalendar);
      expect(r.season, FastSeason.nativityFast);
      expect(r.level, FastLevel.strict); // Friday, base strict
    });

    test('Old calendar: civil Jan 7 is fast-free (Julian Nativity)', () {
      final r = day(2027, 1, 7, Calendar.oldCalendar);
      expect(r.level, FastLevel.fastFree);
      expect(r.titleKey, 'season.nativityToTheophany');
    });
  });

  group('smoke: engine is total over many years', () {
    test('every day 2020–2033 computes a valid verdict', () {
      var d = DateTime(2020, 1, 1);
      final end = DateTime(2034, 1, 1);
      var count = 0;
      while (d.isBefore(end)) {
        final r = computeFastingDay(d);
        expect(FastLevel.values.contains(r.level), isTrue);
        // Allowed-foods mapping must be internally consistent.
        if (r.level == FastLevel.strict) {
          expect(r.allowed.oil, isFalse);
          expect(r.allowed.fish, isFalse);
        }
        if (r.level == FastLevel.fastFree) {
          expect(r.allowed.meat, isTrue);
        }
        d = d.add(const Duration(days: 1));
        count++;
      }
      expect(count, greaterThan(5000));
    });
  });
}
