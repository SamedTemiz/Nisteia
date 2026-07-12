import 'package:flutter_test/flutter_test.dart';
import 'package:nisteia/core/paschalion.dart';

void main() {
  group('paschaGregorian — known Orthodox Pascha civil dates', () {
    // Civil (Gregorian) dates of Orthodox Pascha, cross-checked against
    // published paschalia. Both New- and Old-calendar Orthodox share these.
    const known = <int, List<int>>{
      2020: [4, 19],
      2021: [5, 2],
      2022: [4, 24],
      2023: [4, 16],
      2024: [5, 5],
      2025: [4, 20],
      2026: [4, 12],
      2027: [5, 2],
      2028: [4, 16],
      2029: [4, 8],
      2030: [4, 28],
      2031: [4, 13],
      2032: [5, 2],
      2033: [4, 24],
      2034: [4, 9],
      2035: [4, 29],
    };

    known.forEach((year, md) {
      test('$year → ${md[0]}/${md[1]}', () {
        final p = paschaGregorian(year);
        expect(p.year, year);
        expect(p.month, md[0]);
        expect(p.day, md[1]);
        expect(p.weekday, DateTime.sunday, reason: 'Pascha is always Sunday');
      });
    });
  });

  group('paschaDistance', () {
    test('Pascha itself is 0', () {
      expect(paschaDistance(DateTime(2026, 4, 12)), 0);
    });

    test('Clean Monday 2026 is -48', () {
      // Great Lent 2026 begins Monday 23 Feb.
      expect(paschaDistance(DateTime(2026, 2, 23)), -48);
    });

    test('Palm Sunday 2026 is -7', () {
      expect(paschaDistance(DateTime(2026, 4, 5)), -7);
    });

    test('Pentecost 2026 is +49', () {
      expect(paschaDistance(DateTime(2026, 5, 31)), 49);
    });
  });
}
