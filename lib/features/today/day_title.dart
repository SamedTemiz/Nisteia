import '../../l10n/generated/app_localizations.dart';

/// Resolves a [DayInfo.titleKey] (a stable engine key like `season.greatLent`)
/// to its localized display string. One switch, because generated ARB
/// getters can't be looked up by string name in Dart.
String resolveDayTitle(String titleKey, AppLocalizations l10n) {
  switch (titleKey) {
    case 'day.pascha':
      return l10n.dayPascha;
    case 'season.brightWeek':
      return l10n.seasonBrightWeek;
    case 'day.pentecost':
      return l10n.dayPentecost;
    case 'season.pentecostWeek':
      return l10n.seasonPentecostWeek;
    case 'season.fastFreeWeek':
      return l10n.seasonFastFreeWeek;
    case 'season.nativityToTheophany':
      return l10n.seasonNativityToTheophany;
    case 'season.cheesefareWeek':
      return l10n.seasonCheesefareWeek;
    case 'season.greatLent':
      return l10n.seasonGreatLent;
    case 'day.lazarusSaturday':
      return l10n.dayLazarusSaturday;
    case 'day.palmSunday':
      return l10n.dayPalmSunday;
    case 'day.holyThursday':
      return l10n.dayHolyThursday;
    case 'day.holyFriday':
      return l10n.dayHolyFriday;
    case 'day.holySaturday':
      return l10n.dayHolySaturday;
    case 'day.annunciation':
      return l10n.dayAnnunciation;
    case 'season.apostlesFast':
      return l10n.seasonApostlesFast;
    case 'season.nativityFast':
      return l10n.seasonNativityFast;
    case 'day.entryOfTheotokos':
      return l10n.dayEntryOfTheotokos;
    case 'day.nativityEve':
      return l10n.dayNativityEve;
    case 'season.dormitionFast':
      return l10n.seasonDormitionFast;
    case 'day.transfiguration':
      return l10n.dayTransfiguration;
    case 'day.theophanyEve':
      return l10n.dayTheophanyEve;
    case 'day.beheadingOfJohn':
      return l10n.dayBeheadingOfJohn;
    case 'day.exaltationOfCross':
      return l10n.dayExaltationOfCross;
    case 'day.wednesdayFriday':
      return l10n.dayWednesdayFriday;
    case 'fastFree':
    default:
      return l10n.fastFree;
  }
}
