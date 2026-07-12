import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nisteia/app/settings.dart';
import 'package:nisteia/main.dart';

Future<ProviderScope> _app({required bool onboarded}) async {
  SharedPreferences.setMockInitialValues(
      onboarded ? {'onboardingComplete': true} : {});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const NisteiaApp(),
  );
}

void main() {
  testWidgets('onboarded user lands on the Today screen', (tester) async {
    await tester.pumpWidget(await _app(onboarded: true));
    await tester.pumpAndSettle();

    // The status card always renders one of the five level labels.
    const levelLabels = [
      'Fast-free',
      'Dairy allowed',
      'Fish, wine & oil',
      'Wine & oil',
      'Strict fast',
    ];
    final foundLevel =
        levelLabels.any((l) => find.text(l).evaluate().isNotEmpty);
    expect(foundLevel, isTrue,
        reason: 'expected one of $levelLabels to render');

    // The five food labels are always present in the status card.
    for (final label in ['Meat', 'Dairy', 'Fish', 'Wine', 'Oil']) {
      expect(find.text(label), findsWidgets);
    }

    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Saints of the Day'), findsOneWidget);
  });

  testWidgets('first run shows onboarding', (tester) async {
    await tester.pumpWidget(await _app(onboarded: false));
    await tester.pumpAndSettle();

    // Onboarding step 1 asks about the calendar.
    expect(find.text('New Calendar'), findsOneWidget);
    expect(find.text('Old Calendar'), findsOneWidget);
  });
}
