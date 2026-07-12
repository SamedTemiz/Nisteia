import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/day_providers.dart';
import '../../core/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../seasons/seasons_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/sources_screen.dart';
import '../shared/day_detail_sheet.dart';
import 'day_saints.dart';
import 'day_title.dart';
import 'level_style.dart';
import 'today_providers.dart';

/// The main screen — "what can I eat today?" answered in one glance.
/// Spec: docs/screens.md §2; design: docs/design-refs/today_nisteia_final.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(todayProvider);
    final l10n = AppLocalizations.of(context)!;

    // Reason line: the day's title, enriched with "· day X of Y" while inside
    // an active fasting season (unless a specific feast already names the day).
    var reason = resolveDayTitle(day.titleKey, l10n);
    final active = ref.watch(seasonOverviewProvider).active;
    if (active != null && day.titleKey.startsWith('season.')) {
      reason = '$reason · day ${active.dayOfSeason} of ${active.totalDays}';
    }

    return Scaffold(
      drawer: const _AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            color: AppColors.gold,
            tooltip: l10n.menuTooltip,
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            fontFamily: kSerif,
            color: AppColors.gold,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            color: AppColors.gold,
            tooltip: l10n.settingsTooltip,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _DateHeader(day: day, l10n: l10n),
              const SizedBox(height: 28),
              _StatusCard(day: day, l10n: l10n, reason: reason),
              const SizedBox(height: 20),
              const _WeekStrip(),
              const SizedBox(height: 20),
              _SaintsCard(day: day, l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation drawer opened by the app-bar menu button: Settings and the
/// data-sources / attribution screen.
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    void go(Widget screen) {
      Navigator.of(context)
        ..pop() // close the drawer first
        ..push(MaterialPageRoute<void>(builder: (_) => screen));
    }

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontFamily: kSerif,
                  color: AppColors.gold,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(color: AppColors.surface, height: 1),
            ListTile(
              leading:
                  const Icon(Icons.settings_outlined, color: AppColors.gold),
              title: Text(l10n.settingsTitle,
                  style: const TextStyle(color: AppColors.ink)),
              onTap: () => go(const SettingsScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined,
                  color: AppColors.gold),
              title: Text(l10n.sourcesTitle,
                  style: const TextStyle(color: AppColors.ink)),
              onTap: () => go(const SourcesScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

/// "TODAY" eyebrow + the civil date and its Old-Style (Julian) counterpart.
class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.day, required this.l10n});

  final DayInfo day;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final civil = DateFormat.MMMMd(locale).format(day.date);
    final os = oldStyleDate(day.date);
    final osText =
        DateFormat.MMMMd(locale).format(DateTime(os.year, os.month, os.day));

    return Column(
      children: [
        Text(l10n.today.toUpperCase(), style: eyebrowStyle(context)),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(children: [
            TextSpan(text: civil),
            const TextSpan(
                text: '   ·   ', style: TextStyle(color: AppColors.inkMuted)),
            TextSpan(text: '$osText ${l10n.oldStyleAbbrev}'),
          ]),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: kSerif,
            fontSize: 22,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

/// The fasting-level card: level name in gold serif, a colour-coded accent for
/// the level (docs/screens.md), and the five-food permission row.
class _StatusCard extends StatelessWidget {
  const _StatusCard(
      {required this.day, required this.l10n, required this.reason});

  final DayInfo day;
  final AppLocalizations l10n;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final levelColor = colorForLevel(day.level);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // Subtle blurred iconography behind the card (6th-c. Pantocrator of
          // Sinai, public domain — assets/images/ATTRIBUTION.md). Kept faint
          // so the fasting verdict stays fully legible.
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Image.asset(
                'assets/images/pantocrator_sinai.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.4),
              ),
            ),
          ),
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.surface.withValues(alpha: 0.82),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Column(
              children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: levelColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(l10n.fastingLevel.toUpperCase(),
                  style: eyebrowStyle(context)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            levelLabel(day.level, l10n),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: kSerif,
              fontSize: 38,
              height: 1.05,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reason,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.inkMuted, fontSize: 14),
          ),
                const SizedBox(height: 20),
                Divider(
                    color: levelColor.withValues(alpha: 0.5), thickness: 1),
                const SizedBox(height: 20),
                _FoodRow(allowed: day.allowed, l10n: l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  const _FoodRow({required this.allowed, required this.l10n});

  final AllowedFoods allowed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    String a11y(String label, bool ok) =>
        '$label: ${ok ? l10n.permitted : l10n.notPermitted}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _FoodIcon(
            icon: Icons.restaurant,
            label: l10n.foodMeat,
            permitted: allowed.meat,
            semanticLabel: a11y(l10n.foodMeat, allowed.meat)),
        _FoodIcon(
            icon: Icons.egg_outlined,
            label: l10n.foodDairy,
            permitted: allowed.dairy,
            semanticLabel: a11y(l10n.foodDairy, allowed.dairy)),
        _FoodIcon(
            icon: Icons.set_meal_outlined,
            label: l10n.foodFish,
            permitted: allowed.fish,
            semanticLabel: a11y(l10n.foodFish, allowed.fish)),
        _FoodIcon(
            icon: Icons.wine_bar_outlined,
            label: l10n.foodWine,
            permitted: allowed.wine,
            semanticLabel: a11y(l10n.foodWine, allowed.wine)),
        _FoodIcon(
            icon: Icons.water_drop_outlined,
            label: l10n.foodOil,
            permitted: allowed.oil,
            semanticLabel: a11y(l10n.foodOil, allowed.oil)),
      ],
    );
  }
}

class _FoodIcon extends StatelessWidget {
  const _FoodIcon({
    required this.icon,
    required this.label,
    required this.permitted,
    required this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final bool permitted;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    const allowColor = Color(0xFF3DA35C);
    final fg = permitted ? AppColors.ink : AppColors.inkMuted;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.inkMuted.withValues(alpha: 0.4)),
                  color: permitted
                      ? allowColor.withValues(alpha: 0.14)
                      : Colors.transparent,
                ),
                child: Icon(icon,
                    size: 24,
                    color: permitted ? fg : fg.withValues(alpha: 0.55)),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(1),
                  child: Icon(
                    permitted ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: permitted ? allowColor : AppColors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// "Saints of the Day" — the fixed-date commemorations for the day.
class _SaintsCard extends StatelessWidget {
  const _SaintsCard({required this.day, required this.l10n});

  final DayInfo day;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final saints = saintsForDay(day);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.saintsOfTheDay,
                style: const TextStyle(
                  fontFamily: kSerif,
                  fontSize: 20,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (saints.isEmpty)
            Text(l10n.noCommemorations,
                style: const TextStyle(color: AppColors.inkMuted))
          else
            ...saints.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 7, right: 10),
                        child: _Bullet(),
                      ),
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 15,
                                height: 1.35)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

/// A seven-day look-ahead: coloured dots for planning the week (docs/screens.md).
class _WeekStrip extends ConsumerWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final week = ref.watch(next7DaysProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 12),
            child: Text(l10n.next7Days, style: eyebrowStyle(context)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final d in week)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => showDayDetailSheet(context, d),
                    child: Column(
                      children: [
                        Text(
                          DateFormat.E(Localizations.localeOf(context)
                                  .toString())
                              .format(d.date)
                              .characters
                              .first
                              .toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.inkMuted, fontSize: 11),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: colorForLevel(d.level),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:
                                    AppColors.inkMuted.withValues(alpha: 0.25)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('${d.date.day}',
                            style: const TextStyle(
                                color: AppColors.ink, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet();

  @override
  Widget build(BuildContext context) => Container(
        width: 5,
        height: 5,
        decoration:
            const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
      );
}
