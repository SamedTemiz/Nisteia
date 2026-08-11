import 'package:flutter/foundation.dart'
    show
        TargetPlatform,
        debugPrint,
        defaultTargetPlatform,
        kIsWeb,
        visibleForTesting;
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/review/review_prompt.dart';

/// Thin platform layer over [shouldAskForReview]: persists the usage history
/// and hands off to Play's native rating sheet. No policy lives here — see
/// review_prompt.dart for the "when/whether" rules.
///
/// There is deliberately no custom "are you enjoying Nisteia?" dialog in front
/// of this. Filtering who reaches the review flow by how happy they seem is a
/// Play policy violation, so the sheet is requested unconditionally once the
/// thresholds are met.
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  static const _kFirstUse = 'review.firstUse';
  static const _kDaysUsed = 'review.daysUsed';
  static const _kLastUsedDay = 'review.lastUsedDay';

  /// Date and count in a single value, because SharedPreferences has no
  /// transaction: as two keys, a crash between the writes could leave a
  /// request recorded but uncounted and let [kMaxAsks] be exceeded.
  static const _kAsks = 'review.asks';

  final InAppReview _review = InAppReview.instance;

  /// A single app switch can deliver several `resumed` events, and each one
  /// calls in here. Without this, two overlapping runs could both get past
  /// [shouldAskForReview] and request the sheet twice.
  bool _busy = false;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Counts today's use and, if the user has earned the question, asks it.
  ///
  /// Called on every launch and every resume from `main.dart`'s `_RootGate`.
  /// Nothing at all happens until onboarding is complete: days spent with setup
  /// unfinished are not days of use, and counting them could put the sheet in
  /// front of someone who has never seen a fasting verdict.
  ///
  /// Never throws. It is launched with `unawaited`, so an escaping error would
  /// become an unhandled async error — and asking for a rating is the least
  /// important thing this app does.
  Future<void> recordUseAndMaybeAsk(
    SharedPreferences prefs, {
    required bool onboardingComplete,
    DateTime? now,
  }) async {
    if (!onboardingComplete || _busy) return;
    _busy = true;
    final at = now ?? DateTime.now();

    try {
      final before = _read(prefs);
      final after = recordUse(before, at);
      if (after != before) await _persist(prefs, after);

      if (!_supported) return;
      if (!shouldAskForReview(after, now: at)) return;
      if (!await _review.isAvailable()) return;

      await _review.requestReview();
      // The API never reports whether the sheet actually appeared, so record
      // the attempt optimistically. kRetryAfterDays grants one later retry and
      // kMaxAsks stops it there — we ask at most twice, ever. One write, so the
      // date and the count can never disagree.
      await prefs.setString(_kAsks, encodeAsks(at, after.askCount + 1));
    } catch (e, st) {
      debugPrint('ReviewService.recordUseAndMaybeAsk failed: $e\n$st');
    } finally {
      _busy = false;
    }
  }

  ReviewState _read(SharedPreferences p) {
    final (askedOn, askCount) = decodeAsks(p.getString(_kAsks));
    return ReviewState(
      firstUse: _date(p, _kFirstUse),
      daysUsed: p.getInt(_kDaysUsed) ?? 0,
      lastUsedDay: _date(p, _kLastUsedDay),
      lastAskedOn: askedOn,
      askCount: askCount,
    );
  }

  Future<void> _persist(SharedPreferences p, ReviewState s) async {
    final first = s.firstUse;
    if (first != null) await p.setString(_kFirstUse, first.toIso8601String());
    await p.setInt(_kDaysUsed, s.daysUsed);
    final last = s.lastUsedDay;
    if (last != null) await p.setString(_kLastUsedDay, last.toIso8601String());
  }

  /// `<iso8601>|<count>` — see [_kAsks] for why these share one key.
  @visibleForTesting
  static String encodeAsks(DateTime at, int count) =>
      '${at.toIso8601String()}|$count';

  /// Anything unparseable reads as "never asked". The only writer is
  /// [encodeAsks], so that means the value was corrupted, and the worst
  /// outcome is one extra prompt.
  @visibleForTesting
  static (DateTime?, int) decodeAsks(String? raw) {
    if (raw == null) return (null, 0);
    final parts = raw.split('|');
    if (parts.length != 2) return (null, 0);
    final at = DateTime.tryParse(parts[0]);
    final count = int.tryParse(parts[1]);
    if (at == null || count == null) return (null, 0);
    return (at, count);
  }

  static DateTime? _date(SharedPreferences p, String key) {
    final raw = p.getString(key);
    return raw == null ? null : DateTime.tryParse(raw);
  }
}
