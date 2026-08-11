import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/home_shell.dart';
import 'app/notification_service.dart';
import 'app/review_service.dart';
import 'app/settings.dart';
import 'features/notifications/notification_plan.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait only. Every screen is a single tall column of cards; in landscape
  // the viewport loses two thirds of its height and the layout degrades into
  // scrolling for one card at a time. Declared here rather than only in the
  // Android manifest so the iOS target inherits it too.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
    final localeCode = ref.watch(settingsProvider.select((s) => s.localeCode));
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
/// first build, then again whenever a relevant setting changes, and counts the
/// launch towards the rating prompt.
class _RootGate extends ConsumerStatefulWidget {
  const _RootGate();

  @override
  ConsumerState<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends ConsumerState<_RootGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      _reschedule(settings);
      _countUse(settings);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Android can keep the process alive for days, so `initState` alone would
  /// miss someone who returns to the app every morning without it ever being
  /// killed — their usage would never accumulate and they'd never be asked to
  /// rate it. Counting on resume as well is what makes "days used" mean days.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _countUse(ref.read(settingsProvider));
    }
  }

  /// Fire-and-forget: the rating sheet is the least important thing here and
  /// must never delay a frame. The service is re-entrancy guarded, so the
  /// several resume events a single app switch can produce are harmless.
  void _countUse(AppSettings settings) {
    unawaited(ReviewService.instance.recordUseAndMaybeAsk(
      ref.read(sharedPreferencesProvider),
      onboardingComplete: settings.onboardingComplete,
    ));
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
      // Catches the session in which onboarding is finished: the post-frame
      // callback above already ran, back when there was nothing to count yet.
      _countUse(next);
    });

    return done ? const HomeShell() : const OnboardingScreen();
  }
}
