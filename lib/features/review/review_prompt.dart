/// When to ask the user to rate Nisteia.
///
/// Pure Dart — no plugin, no SharedPreferences, no Flutter — so the whole
/// policy is unit-testable and the service around it stays a dumb pipe. Same
/// split as notification_plan.dart / notification_service.dart.
library;

/// The app must have been used on this many *separate* days. Opening it ten
/// times in one afternoon says nothing; coming back on a third day is the
/// first real signal that someone has made it part of their routine.
const int kMinDistinctDaysUsed = 3;

/// A belt-and-braces floor on elapsed time. [kMinDistinctDaysUsed] already
/// implies two days have passed, so this only matters if the device clock
/// jumps (timezone change, manual adjustment) and inflates the day count.
const int kMinDaysSinceFirstUse = 2;

/// Play keeps an undisclosed per-user quota and never tells us whether the
/// sheet actually appeared, so a request may in fact have shown nothing. After
/// this long, try once more rather than staying silent forever on a request
/// that may have been swallowed.
const int kRetryAfterDays = 120;

/// Hard ceiling on how many times we will ever ask. Without it, [kRetryAfterDays]
/// alone would re-ask every 120 days forever, which is both nagging and against
/// Play's guidance on request frequency. Two attempts: the first, and one
/// insurance attempt in case the quota silently ate it.
const int kMaxAsks = 2;

/// Everything we remember about this user's history with the app. Dates are
/// day-granular; the time of day is never significant here.
class ReviewState {
  const ReviewState({
    this.firstUse,
    this.daysUsed = 0,
    this.lastUsedDay,
    this.lastAskedOn,
    this.askCount = 0,
  });

  /// The first day the app was used *after finishing onboarding*, or null
  /// before that. Launches during onboarding are never recorded: half-finished
  /// setup is not use of the product, and counting it could put the rating
  /// sheet in front of someone who has not yet seen a single day's verdict.
  final DateTime? firstUse;

  /// How many separate days the app has been used on.
  final int daysUsed;

  /// The most recent day already counted towards [daysUsed].
  final DateTime? lastUsedDay;

  /// When the rating sheet was last requested, if ever.
  final DateTime? lastAskedOn;

  /// How many times the sheet has been requested. Capped by [kMaxAsks].
  final int askCount;

  ReviewState copyWith({
    DateTime? firstUse,
    int? daysUsed,
    DateTime? lastUsedDay,
    DateTime? lastAskedOn,
    int? askCount,
  }) =>
      ReviewState(
        firstUse: firstUse ?? this.firstUse,
        daysUsed: daysUsed ?? this.daysUsed,
        lastUsedDay: lastUsedDay ?? this.lastUsedDay,
        lastAskedOn: lastAskedOn ?? this.lastAskedOn,
        askCount: askCount ?? this.askCount,
      );

  @override
  bool operator ==(Object other) =>
      other is ReviewState &&
      other.firstUse == firstUse &&
      other.daysUsed == daysUsed &&
      other.lastUsedDay == lastUsedDay &&
      other.lastAskedOn == lastAskedOn &&
      other.askCount == askCount;

  @override
  int get hashCode =>
      Object.hash(firstUse, daysUsed, lastUsedDay, lastAskedOn, askCount);

  @override
  String toString() => 'ReviewState(first=$firstUse, days=$daysUsed, '
      'last=$lastUsedDay, asked=$lastAskedOn x$askCount)';
}

/// Folds a day of use at [now] into [state]. Returns [state] unchanged when the
/// app has already been used today, so the caller can skip the write.
///
/// The caller is responsible for only invoking this once onboarding is
/// complete — see [ReviewState.firstUse].
ReviewState recordUse(ReviewState state, DateTime now) {
  final today = _dayOf(now);
  final last = state.lastUsedDay;
  if (last != null && _dayOf(last) == today) return state;
  return state.copyWith(
    firstUse: state.firstUse ?? today,
    daysUsed: state.daysUsed + 1,
    lastUsedDay: today,
  );
}

/// Whether to request the store's rating sheet right now.
bool shouldAskForReview(ReviewState state, {required DateTime now}) {
  if (state.askCount >= kMaxAsks) return false;

  final first = state.firstUse;
  if (first == null) return false;

  if (state.daysUsed < kMinDistinctDaysUsed) return false;
  if (_daysBetween(first, now) < kMinDaysSinceFirstUse) return false;

  final asked = state.lastAskedOn;
  if (asked != null && _daysBetween(asked, now) < kRetryAfterDays) return false;

  return true;
}

DateTime _dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

/// Whole calendar days from [a] to [b]. Rounded from hours because a local
/// day is not always 24 long — across a DST change a raw `inDays` is off by
/// one, which would silently shift every threshold in this file.
int _daysBetween(DateTime a, DateTime b) =>
    (_dayOf(b).difference(_dayOf(a)).inHours / 24).round();
