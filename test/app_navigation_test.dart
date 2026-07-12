import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nisteia/app/settings.dart';
import 'package:nisteia/main.dart';

Future<Widget> _app(Map<String, Object> seed) async {
  SharedPreferences.setMockInitialValues(seed);
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const NisteiaApp(),
  );
}

void main() {
  testWidgets('bottom nav switches between the four tabs', (tester) async {
    await tester.pumpWidget(await _app({'onboardingComplete': true}));
    await tester.pumpAndSettle();

    // Calendar tab.
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.text('STRICT'), findsNothing); // legend uses level labels
    expect(find.byIcon(Icons.chevron_left), findsOneWidget); // month nav

    // Seasons tab.
    await tester.tap(find.text('Seasons'));
    await tester.pumpAndSettle();
    expect(find.textContaining('days'), findsWidgets);

    // Guide tab.
    await tester.tap(find.text('Guide'));
    await tester.pumpAndSettle();
    expect(find.text('Allowed today'), findsOneWidget);
    expect(find.text('Avoided today'), findsOneWidget);
  });

  testWidgets('settings opens from the Today app bar and toggles calendar',
      (tester) async {
    await tester.pumpWidget(await _app({'onboardingComplete': true}));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.account_circle_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    // Switch to the Old Calendar and confirm the option reflects selection.
    await tester.tap(find.text('Old Calendar'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.radio_button_checked), findsWidgets);
  });

  testWidgets('calendar shows the paywall when leaving the free window',
      (tester) async {
    await tester.pumpWidget(await _app({'onboardingComplete': true}));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    // Current + next month are free; the second forward step leaves the window.
    final next = find.byIcon(Icons.chevron_right);
    await tester.tap(next);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();

    expect(
        find.text('No subscription. Pay once, keep forever.'), findsOneWidget);
  });

  testWidgets('onboarding can be completed to reach the shell', (tester) async {
    await tester.pumpWidget(await _app({}));
    await tester.pumpAndSettle();

    // Three "Next"/"Get started" taps advance and finish onboarding.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // We land on the Today screen (its eyebrow is unique).
    expect(find.text('TODAY'), findsOneWidget);
  });
}
