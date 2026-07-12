import 'package:flutter_test/flutter_test.dart';
import 'package:nisteia/core/fasting_rules.dart';
import 'package:nisteia/core/models.dart';
import 'package:nisteia/features/today/day_saints.dart';

void main() {
  group('saintsForDay respects the calendar mode', () {
    test('New calendar: civil July 12 commemorates the Ancyra martyrs', () {
      final day = computeFastingDay(DateTime(2026, 7, 12),
          calendar: Calendar.newCalendar);
      expect(
          saintsForDay(day), contains('Martyrs Proclus and Hilary of Ancyra'));
    });

    test('Old calendar: civil July 12 (Julian June 29) is Peter and Paul', () {
      final day = computeFastingDay(DateTime(2026, 7, 12),
          calendar: Calendar.oldCalendar);
      expect(saintsForDay(day), contains('Holy Apostles Peter and Paul'));
    });
  });

  test('oldStyleDate maps civil July 12 2026 to Julian June 29', () {
    final os = oldStyleDate(DateTime(2026, 7, 12));
    expect((os.month, os.day), (6, 29));
  });
}
