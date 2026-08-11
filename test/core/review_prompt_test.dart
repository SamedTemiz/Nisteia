import 'package:flutter_test/flutter_test.dart';
import 'package:nisteia/features/review/review_prompt.dart';

void main() {
  group('recordUse', () {
    test('first day of use seeds the history', () {
      final s = recordUse(const ReviewState(), DateTime(2026, 8, 10, 21, 30));

      expect(s.firstUse, DateTime(2026, 8, 10));
      expect(s.daysUsed, 1);
      expect(s.lastUsedDay, DateTime(2026, 8, 10));
      // The clock time is dropped: only the calendar day matters.
      expect(s.firstUse!.hour, 0);
    });

    test('opening again the same day changes nothing', () {
      final morning = recordUse(const ReviewState(), DateTime(2026, 8, 10, 8));
      final evening = recordUse(morning, DateTime(2026, 8, 10, 23, 59));

      expect(evening, morning, reason: 'caller should skip the write');
      expect(evening.daysUsed, 1);
    });

    test('a new day counts, across a month boundary', () {
      var s = recordUse(const ReviewState(), DateTime(2026, 1, 31));
      s = recordUse(s, DateTime(2026, 2, 1));

      expect(s.daysUsed, 2);
      expect(s.firstUse, DateTime(2026, 1, 31));
      expect(s.lastUsedDay, DateTime(2026, 2, 1));
    });

    test('gaps do not reset the count', () {
      var s = recordUse(const ReviewState(), DateTime(2026, 8, 1));
      s = recordUse(s, DateTime(2026, 9, 15));

      expect(s.daysUsed, 2);
      expect(s.firstUse, DateTime(2026, 8, 1));
    });
  });

  group('shouldAskForReview', () {
    /// History for a user who used the app on [days] consecutive days starting
    /// 10 Aug 2026.
    ReviewState afterConsecutiveDays(int days) {
      var s = const ReviewState();
      for (var i = 0; i < days; i++) {
        s = recordUse(s, DateTime(2026, 8, 10 + i));
      }
      return s;
    }

    test('never before any recorded use', () {
      // firstUse stays null until onboarding is done, so this also covers
      // "never during onboarding" — the service records nothing until then.
      expect(
        shouldAskForReview(const ReviewState(), now: DateTime(2026, 8, 10)),
        isFalse,
      );
    });

    test('not after two days of use', () {
      expect(
        shouldAskForReview(afterConsecutiveDays(2), now: DateTime(2026, 8, 11)),
        isFalse,
      );
    });

    test('asks on the third distinct day', () {
      expect(
        shouldAskForReview(afterConsecutiveDays(3), now: DateTime(2026, 8, 12)),
        isTrue,
      );
    });

    test('a day count without elapsed days does not earn the question', () {
      // Guards the case where a device clock jump inflates daysUsed without
      // real time having passed.
      final sameDay = ReviewState(
        firstUse: DateTime(2026, 8, 10),
        daysUsed: 5,
        lastUsedDay: DateTime(2026, 8, 10),
      );

      expect(shouldAskForReview(sameDay, now: DateTime(2026, 8, 10)), isFalse);
    });

    test('stays quiet inside the retry window', () {
      final s = afterConsecutiveDays(5)
          .copyWith(lastAskedOn: DateTime(2026, 8, 14), askCount: 1);

      expect(shouldAskForReview(s, now: DateTime(2026, 8, 20)), isFalse);
      expect(
        shouldAskForReview(s, now: DateTime(2026, 11, 1)),
        isFalse,
        reason: 'still inside the $kRetryAfterDays-day retry window',
      );
    });

    test('tries once more long after a request that may have been swallowed',
        () {
      final s = afterConsecutiveDays(5)
          .copyWith(lastAskedOn: DateTime(2026, 8, 14), askCount: 1);
      final wellAfter =
          DateTime(2026, 8, 14).add(const Duration(days: kRetryAfterDays + 1));

      expect(shouldAskForReview(s, now: wellAfter), isTrue);
    });

    test('never asks a third time, however long it has been', () {
      final s = afterConsecutiveDays(5)
          .copyWith(lastAskedOn: DateTime(2026, 8, 14), askCount: kMaxAsks);

      // Years later: the retry window has long since passed, but the ceiling
      // holds. Without it, kRetryAfterDays would re-ask every 120 days forever.
      expect(shouldAskForReview(s, now: DateTime(2030, 1, 1)), isFalse);
    });
  });
}
