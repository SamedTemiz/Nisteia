import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/models.dart';
import '../features/notifications/notification_plan.dart';
import '../l10n/generated/app_localizations.dart';

/// Thin platform layer over [planNotifications]: turns the pure, fully-tested
/// plan into actually-scheduled local notifications. No fasting logic lives
/// here — see notification_plan.dart for the "when/whether" rules.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> init() async {
    if (!_supported || _initialized) return;
    try {
      tz_data.initializeTimeZones();
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      _initialized = true;
    } catch (e, st) {
      // Scheduling reminders is best-effort — never take the app down with it
      // (also covers environments with no real plugin channel, e.g. tests).
      debugPrint('NotificationService.init failed: $e\n$st');
    }
  }

  Future<void> _requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Cancels everything previously scheduled and schedules [planned] fresh.
  /// Called once when onboarding completes and again whenever the user's
  /// notification prefs or calendar mode change (see main.dart `_RootGate`).
  Future<void> reschedule(
    List<PlannedNotification> planned,
    AppLocalizations l10n,
  ) async {
    if (!_supported) return;
    try {
      await init();
      if (!_initialized) return; // init() failed — nothing to schedule onto
      await _requestPermission();
      await _plugin.cancelAll();

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'fasting_reminders',
          'Fasting reminders',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      );

      final now = tz.TZDateTime.now(tz.local);
      for (final n in planned) {
        final when = tz.TZDateTime.from(n.when, tz.local);
        if (when.isBefore(now)) continue;
        await _plugin.zonedSchedule(
          _idFor(n.forDate),
          _title(n, l10n),
          _body(n, l10n),
          when,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e, st) {
      debugPrint('NotificationService.reschedule failed: $e\n$st');
    }
  }

  /// Stable per-day notification id (fits comfortably in 32 bits).
  int _idFor(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

  String _title(PlannedNotification n, AppLocalizations l10n) =>
      switch (n.kind) {
        NotificationKind.seasonStart => l10n.notifySeasonStartTitle,
        NotificationKind.fastEve => l10n.notifyFastEveTitle,
      };

  String _body(PlannedNotification n, AppLocalizations l10n) =>
      switch (n.kind) {
        NotificationKind.seasonStart =>
          l10n.notifySeasonStartBody(_seasonName(n.season, l10n)),
        NotificationKind.fastEve =>
          l10n.notifyFastEveBody(_levelName(n.level, l10n)),
      };

  String _seasonName(FastSeason season, AppLocalizations l10n) =>
      switch (season) {
        FastSeason.greatLent => l10n.seasonGreatLent,
        FastSeason.apostlesFast => l10n.seasonApostlesFast,
        FastSeason.nativityFast => l10n.seasonNativityFast,
        FastSeason.dormitionFast => l10n.seasonDormitionFast,
        FastSeason.cheesefareWeek => l10n.seasonCheesefareWeek,
        FastSeason.none => '',
      };

  String _levelName(FastLevel level, AppLocalizations l10n) =>
      switch (level) {
        FastLevel.strict => l10n.levelStrict,
        FastLevel.wineOil => l10n.levelWineOil,
        FastLevel.fishWineOil => l10n.levelFishWineOil,
        FastLevel.dairyAllowed => l10n.levelDairyAllowed,
        FastLevel.fastFree => l10n.levelFastFree,
      };
}
