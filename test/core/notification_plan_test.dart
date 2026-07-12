import 'package:flutter_test/flutter_test.dart';
import 'package:nisteia/core/models.dart';
import 'package:nisteia/features/notifications/notification_plan.dart';

void main() {
  // Liturgical year 2026: Pascha = Sun 12 Apr 2026 (New calendar).
  group('planNotifications', () {
    test('ordinary week: reminds the eve of Wednesday and Friday fasts', () {
      // Mon 6 Jul 2026 is ordinary time (well after Pentecost, before fasts).
      final plan = planNotifications(
        DateTime(2026, 7, 6),
        eveningReminder: true,
        seasonAlerts: true,
        horizonDays: 7,
      );

      final fastEves = plan.where((n) => n.kind == NotificationKind.fastEve);
      // Wed 8 Jul and Fri 10 Jul are fasts; their eves are Tue 7 and Thu 9.
      expect(
        fastEves.map((n) => n.forDate.day).toSet(),
        {8, 10},
      );
      // Each fires at 19:00 the previous evening.
      final wed = fastEves.firstWhere((n) => n.forDate.day == 8);
      expect(wed.when, DateTime(2026, 7, 7, 19));
      expect(wed.level, FastLevel.strict);
    });

    test('respects the eveningReminder toggle', () {
      final plan = planNotifications(
        DateTime(2026, 7, 6),
        eveningReminder: false,
        seasonAlerts: false,
        horizonDays: 7,
      );
      expect(plan, isEmpty);
    });

    test('fires a season-start alert the eve of Great Lent', () {
      // Clean Monday 2026 = Mon 23 Feb; its eve is Sun 22 Feb.
      final plan = planNotifications(
        DateTime(2026, 2, 15),
        eveningReminder: true,
        seasonAlerts: true,
        horizonDays: 15,
      );
      final seasonStarts =
          plan.where((n) => n.kind == NotificationKind.seasonStart).toList();
      expect(seasonStarts, hasLength(1));
      expect(seasonStarts.single.forDate, DateTime(2026, 2, 23));
      expect(seasonStarts.single.season, FastSeason.greatLent);
      expect(seasonStarts.single.when, DateTime(2026, 2, 22, 19));
    });

    test('does not double-fire a fast-eve on a season-start evening', () {
      final plan = planNotifications(
        DateTime(2026, 2, 15),
        eveningReminder: true,
        seasonAlerts: true,
        horizonDays: 15,
      );
      final onCleanMondayEve =
          plan.where((n) => n.forDate == DateTime(2026, 2, 23)).toList();
      expect(onCleanMondayEve, hasLength(1));
      expect(onCleanMondayEve.single.kind, NotificationKind.seasonStart);
    });
  });
}
