/// Domain models for the fasting rule engine.
///
/// These are the vocabulary the whole app speaks. The engine
/// (fasting_rules.dart) produces a [DayInfo]; every UI screen reads from it.
///
/// FLUTTER IMPORT FORBIDDEN in this file (architecture principle #2). Any
/// human-facing string here is a *stable key*, not display text — the UI maps
/// keys to localized strings via ARB (architecture principle #3).
library;

/// Which calendar the user follows for **fixed** feasts. The moveable cycle
/// (Pascha) is Julian for everyone, so this only shifts fixed-date feasts.
enum Calendar {
  /// New / Revised Julian calendar (fixed feasts on the civil date).
  newCalendar,

  /// Old / Julian calendar (fixed feasts fall 13 days later, civil).
  oldCalendar,
}

/// What the faithful may eat on a given day, from most permissive to most
/// strict. This is the single number that answers "what can I eat today?".
///
/// The order matters: `index` increases with strictness, so `a.index >
/// b.index` means "a is stricter than b".
enum FastLevel {
  /// No fast. Everything permitted.
  fastFree,

  /// Abstain from meat only; dairy, eggs and fish permitted. (Cheesefare
  /// week — the week before Great Lent.)
  dairyAllowed,

  /// Fasting day, but fish, wine and oil permitted. (Great feasts inside a
  /// fast: Annunciation, Palm Sunday, Transfiguration.)
  fishWineOil,

  /// Fasting day; wine and oil permitted but no fish. (Lenten weekends and
  /// lesser feasts.)
  wineOil,

  /// Strict fast / xerophagy: no meat, dairy, fish, wine or oil. (Lenten
  /// weekdays, strict Wednesdays and Fridays.)
  strict,
}

/// Why today has the fast level it does — drives the "reason" line in the UI.
enum FastReason {
  /// No fast, ordinary day.
  none,

  /// A fast-free week overrides the usual Wednesday/Friday fast (Bright Week,
  /// Nativity–Theophany, Publican & Pharisee week, week after Pentecost).
  fastFreeWeek,

  /// The regular weekly Wednesday/Friday fast, outside any fasting season.
  weekday,

  /// Inside a fasting season (Great Lent, Apostles', Dormition, Nativity).
  season,

  /// A feast raises or lowers the day's strictness (e.g. fish allowed).
  feast,
}

/// The named fasting season a day falls in, or [none].
enum FastSeason {
  none,
  greatLent,
  apostlesFast,
  dormitionFast,
  nativityFast,

  /// Cheesefare week (dairy allowed) — the week that precedes Great Lent.
  cheesefareWeek,
}

/// Concrete list of food groups permitted on a [FastLevel]. Derived, not
/// stored — kept here so the UI icon row (🥩🧀🐟🫒🍷) has one source of truth.
class AllowedFoods {
  const AllowedFoods({
    required this.meat,
    required this.dairy,
    required this.fish,
    required this.wine,
    required this.oil,
  });

  final bool meat;
  final bool dairy;
  final bool fish;
  final bool wine;
  final bool oil;

  /// The canonical mapping from a fast level to permitted food groups.
  factory AllowedFoods.forLevel(FastLevel level) {
    switch (level) {
      case FastLevel.fastFree:
        return const AllowedFoods(
            meat: true, dairy: true, fish: true, wine: true, oil: true);
      case FastLevel.dairyAllowed:
        return const AllowedFoods(
            meat: false, dairy: true, fish: true, wine: true, oil: true);
      case FastLevel.fishWineOil:
        return const AllowedFoods(
            meat: false, dairy: false, fish: true, wine: true, oil: true);
      case FastLevel.wineOil:
        return const AllowedFoods(
            meat: false, dairy: false, fish: false, wine: true, oil: true);
      case FastLevel.strict:
        return const AllowedFoods(
            meat: false, dairy: false, fish: false, wine: false, oil: false);
    }
  }
}

/// The full fasting verdict for a single day — the engine's output.
class DayInfo {
  const DayInfo({
    required this.date,
    required this.calendar,
    required this.paschaDistance,
    required this.level,
    required this.reason,
    required this.season,
    required this.titleKey,
    this.commemorations = const [],
  });

  /// The civil (Gregorian) date this verdict is for.
  final DateTime date;

  /// Which calendar mode produced it.
  final Calendar calendar;

  /// Signed distance in days from Pascha of the same civil year.
  final int paschaDistance;

  /// What may be eaten.
  final FastLevel level;

  /// Why.
  final FastReason reason;

  /// The named season (or [FastSeason.none]).
  final FastSeason season;

  /// Stable i18n key naming the day/season (e.g. `season.greatLent`,
  /// `day.palmSunday`, `fastFree`). The UI resolves it via ARB.
  final String titleKey;

  /// Major commemoration name-keys for the day (saint/feast *names* only in
  /// v1 — no copyrighted biographies). Empty until the data layer is wired.
  final List<String> commemorations;

  /// Food groups permitted today.
  AllowedFoods get allowed => AllowedFoods.forLevel(level);

  @override
  String toString() => 'DayInfo(${date.toIso8601String().substring(0, 10)}, '
      'pdist=$paschaDistance, level=$level, reason=$reason, '
      'season=$season, title=$titleKey)';
}
