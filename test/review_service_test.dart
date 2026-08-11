import 'package:flutter_test/flutter_test.dart';
import 'package:nisteia/app/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The pure policy is covered in test/core/review_prompt_test.dart. What can
/// only be checked here is the sequencing the service owns: that nothing is
/// recorded before onboarding finishes, so the usage clock starts when the
/// user actually starts using the app.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> freshPrefs() async {
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance();
  }

  test('records nothing while onboarding is unfinished', () async {
    final prefs = await freshPrefs();

    // Three days of opening the app without ever finishing setup.
    for (var day = 10; day < 13; day++) {
      await ReviewService.instance.recordUseAndMaybeAsk(
        prefs,
        onboardingComplete: false,
        now: DateTime(2026, 8, day),
      );
    }

    expect(prefs.getKeys().where((k) => k.startsWith('review.')), isEmpty,
        reason: 'days spent in onboarding are not days of use');
  });

  test('starts counting from the first day after onboarding', () async {
    final prefs = await freshPrefs();

    await ReviewService.instance.recordUseAndMaybeAsk(
      prefs,
      onboardingComplete: false,
      now: DateTime(2026, 8, 10),
    );
    await ReviewService.instance.recordUseAndMaybeAsk(
      prefs,
      onboardingComplete: true,
      now: DateTime(2026, 8, 14),
    );

    expect(prefs.getInt('review.daysUsed'), 1);
    expect(
      DateTime.parse(prefs.getString('review.firstUse')!),
      DateTime(2026, 8, 14),
      reason: 'not the 10th, when setup was still unfinished',
    );
  });

  test('the same day is only counted once', () async {
    final prefs = await freshPrefs();

    for (final hour in [8, 13, 22]) {
      await ReviewService.instance.recordUseAndMaybeAsk(
        prefs,
        onboardingComplete: true,
        now: DateTime(2026, 8, 14, hour),
      );
    }

    expect(prefs.getInt('review.daysUsed'), 1);
  });

  group('ask record round-trip', () {
    test('survives encode/decode intact', () {
      final encoded = ReviewService.encodeAsks(DateTime(2026, 8, 14), 2);
      final (at, count) = ReviewService.decodeAsks(encoded);

      expect(at, DateTime(2026, 8, 14));
      expect(count, 2, reason: 'the cap is only enforceable if it survives');
    });

    test('reads as never-asked when absent or damaged', () {
      for (final raw in [null, '', 'garbage', '2026-08-14T00:00:00.000', '|1']) {
        expect(ReviewService.decodeAsks(raw), (null, 0), reason: 'raw=$raw');
      }
    });
  });
}
