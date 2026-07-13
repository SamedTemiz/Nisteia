import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/home_shell.dart';
import 'app/notification_service.dart';
import 'app/settings.dart';
import 'features/notifications/notification_plan.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const NisteiaApp(),
    ),
  );
  // Fire-and-forget, after the first frame: notification setup must never be
  // able to block (or, if a plugin misbehaves, blank) the app's launch.
  unawaited(NotificationService.instance.init());
}

class NisteiaApp extends ConsumerWidget {
  const NisteiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode =
        ref.watch(settingsProvider.select((s) => s.localeCode));
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // English first: Flutter falls back to the FIRST supported locale when
      // the device language isn't supported (otherwise it would pick the
      // alphabetically-first ARB — Bulgarian).
      supportedLocales: [
        const Locale('en'),
        ...AppLocalizations.supportedLocales
            .where((l) => l.languageCode != 'en'),
      ],
      locale: localeCode == null ? null : Locale(localeCode),
      themeMode: ThemeMode.dark,
      darkTheme: buildAppTheme(),
      home: const _RootGate(),
    );
  }
}

/// Shows onboarding until it is complete, then the main navigation shell.
/// Also keeps scheduled notifications in sync with the user's prefs: once on
/// first build, then again whenever a relevant setting changes.
class _RootGate extends ConsumerStatefulWidget {
  const _RootGate();

  @override
  ConsumerState<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends ConsumerState<_RootGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _reschedule(ref.read(settingsProvider)));
  }

  void _reschedule(AppSettings settings) {
    if (!settings.onboardingComplete || !mounted) return;
    final planned = planNotifications(
      DateTime.now(),
      eveningReminder: settings.eveningReminder,
      seasonAlerts: settings.seasonAlerts,
      calendar: settings.calendar,
    );
    unawaited(NotificationService.instance
        .reschedule(planned, AppLocalizations.of(context)!));
  }

  @override
  Widget build(BuildContext context) {
    final done =
        ref.watch(settingsProvider.select((s) => s.onboardingComplete));

    ref.listen(settingsProvider, (prev, next) {
      if (!next.onboardingComplete) return;
      if (prev != null &&
          prev.onboardingComplete == next.onboardingComplete &&
          prev.eveningReminder == next.eveningReminder &&
          prev.seasonAlerts == next.seasonAlerts &&
          prev.calendar == next.calendar) {
        return;
      }
      _reschedule(next);
    });

    return done ? const HomeShell() : const OnboardingScreen();
  }
}
