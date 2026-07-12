import 'package:flutter_test/flutter_test.dart';
import 'package:nisteia/core/calendar_math.dart';

void main() {
  group('Gregorian JDN', () {
    test('known anchor: 2000-01-01 == JDN 2451545', () {
      expect(gregorianToJdn(2000, 1, 1), 2451545);
    });

    test('round-trips over a wide date range', () {
      for (var y = 1900; y <= 2100; y += 7) {
        for (final md in const [
          [1, 1],
          [2, 28],
          [3, 1],
          [7, 15],
          [12, 31],
        ]) {
          final jdn = gregorianToJdn(y, md[0], md[1]);
          final back = jdnToGregorian(jdn);
          expect(back, (year: y, month: md[0], day: md[1]),
              reason: 'gregorian $y-${md[0]}-${md[1]}');
        }
      }
    });
  });

  group('Julian JDN', () {
    test('round-trips over a wide date range', () {
      for (var y = 1900; y <= 2100; y += 7) {
        for (final md in const [
          [1, 1],
          [6, 30],
          [12, 25],
        ]) {
          final jdn = julianToJdn(y, md[0], md[1]);
          final back = jdnToJulian(jdn);
          expect(back, (year: y, month: md[0], day: md[1]),
              reason: 'julian $y-${md[0]}-${md[1]}');
        }
      }
    });
  });

  group('Julian vs Gregorian offset', () {
    test('13 days apart in the 1900–2099 range', () {
      // Same y/m/d label; the Julian calendar day lands 13 later → larger JDN.
      expect(julianToJdn(2000, 1, 1) - gregorianToJdn(2000, 1, 1), 13);
      expect(julianToJdn(2026, 12, 25) - gregorianToJdn(2026, 12, 25), 13);
    });

    test('10 days apart around the 1582 Gregorian reform', () {
      expect(julianToJdn(1582, 10, 10) - gregorianToJdn(1582, 10, 10), 10);
    });
  });

  group('julianYmdOfDate', () {
    test('civil Jan 7 maps to Julian Dec 25 (Old-calendar Nativity)', () {
      final j = julianYmdOfDate(DateTime(2027, 1, 7));
      expect(j.month, 12);
      expect(j.day, 25);
      expect(j.year, 2026);
    });
  });
}
