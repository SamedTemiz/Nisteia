import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models.dart';

/// How strictly the user keeps the fast. v1 computes the **common parish**
/// practice for everyone (that is what the engine is validated against, via
/// orthocal). [monastic] is stored as a preference for a future engine variant
/// but does not yet change the verdict — see ROADMAP Faz 2.
enum Strictness { common, monastic }

/// All user preferences. Local-only, no account (architecture principle #1).
class AppSettings {
  const AppSettings({
    this.calendar = Calendar.newCalendar,
    this.strictness = Strictness.common,
    this.onboardingComplete = false,
    this.eveningReminder = true,
    this.seasonAlerts = true,
    this.localeCode,
  });

  final Calendar calendar;
  final Strictness strictness;
  final bool onboardingComplete;

  /// Evening "tomorrow is a fast day" reminder.
  final bool eveningReminder;

  /// Alerts when a new fasting season begins.
  final bool seasonAlerts;

  /// Explicit app language ('en', 'el', 'ru', …) or null to follow the system.
  final String? localeCode;

  AppSettings copyWith({
    Calendar? calendar,
    Strictness? strictness,
    bool? onboardingComplete,
    bool? eveningReminder,
    bool? seasonAlerts,
    String? localeCode,
    bool clearLocale = false,
  }) =>
      AppSettings(
        calendar: calendar ?? this.calendar,
        strictness: strictness ?? this.strictness,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        eveningReminder: eveningReminder ?? this.eveningReminder,
        seasonAlerts: seasonAlerts ?? this.seasonAlerts,
        localeCode: clearLocale ? null : (localeCode ?? this.localeCode),
      );
}

/// Bound to the real [SharedPreferences] in `main()` via a ProviderScope
/// override; throws if used before that wiring (fail fast in tests that forget).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  static const _kCalendar = 'calendar'; // 'new' | 'old'
  static const _kStrictness = 'strictness'; // 'common' | 'monastic'
  static const _kOnboarding = 'onboardingComplete';
  static const _kEveningReminder = 'eveningReminder';
  static const _kSeasonAlerts = 'seasonAlerts';
  static const _kLocale = 'localeCode'; // absent = system default

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final p = _prefs;
    return AppSettings(
      calendar: p.getString(_kCalendar) == 'old'
          ? Calendar.oldCalendar
          : Calendar.newCalendar,
      strictness: p.getString(_kStrictness) == 'monastic'
          ? Strictness.monastic
          : Strictness.common,
      onboardingComplete: p.getBool(_kOnboarding) ?? false,
      eveningReminder: p.getBool(_kEveningReminder) ?? true,
      seasonAlerts: p.getBool(_kSeasonAlerts) ?? true,
      localeCode: p.getString(_kLocale),
    );
  }

  /// Pass null to follow the system language again.
  Future<void> setLocale(String? code) async {
    state = code == null
        ? state.copyWith(clearLocale: true)
        : state.copyWith(localeCode: code);
    if (code == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, code);
    }
  }

  Future<void> setCalendar(Calendar calendar) async {
    state = state.copyWith(calendar: calendar);
    await _prefs.setString(
        _kCalendar, calendar == Calendar.oldCalendar ? 'old' : 'new');
  }

  Future<void> setStrictness(Strictness strictness) async {
    state = state.copyWith(strictness: strictness);
    await _prefs.setString(_kStrictness,
        strictness == Strictness.monastic ? 'monastic' : 'common');
  }

  Future<void> setEveningReminder(bool value) async {
    state = state.copyWith(eveningReminder: value);
    await _prefs.setBool(_kEveningReminder, value);
  }

  Future<void> setSeasonAlerts(bool value) async {
    state = state.copyWith(seasonAlerts: value);
    await _prefs.setBool(_kSeasonAlerts, value);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingComplete: true);
    await _prefs.setBool(_kOnboarding, true);
  }
}
