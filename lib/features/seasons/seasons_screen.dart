import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/settings.dart';
import '../../core/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'season_math.dart';

final seasonOverviewProvider = Provider<SeasonOverview>((ref) {
  final calendar = ref.watch(settingsProvider.select((s) => s.calendar));
  return computeSeasonOverview(DateTime.now(), calendar: calendar);
});

String seasonLabel(FastSeason s, AppLocalizations l10n) => switch (s) {
      FastSeason.greatLent => l10n.seasonGreatLent,
      FastSeason.apostlesFast => l10n.seasonApostlesFast,
      FastSeason.dormitionFast => l10n.seasonDormitionFast,
      FastSeason.nativityFast => l10n.seasonNativityFast,
      FastSeason.cheesefareWeek => l10n.seasonCheesefareWeek,
      FastSeason.none => l10n.levelFastFree,
    };

/// Seasons & countdown: the next major fast, progress through an active fast,
/// and the year's four great fasts (docs/screens.md §4).
class SeasonsScreen extends ConsumerWidget {
  const SeasonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final overview = ref.watch(seasonOverviewProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(l10n.seasonsTitle,
            style: const TextStyle(
                fontFamily: kSerif, color: AppColors.gold, fontSize: 22)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            if (overview.active != null)
              _ActiveCard(active: overview.active!, l10n: l10n),
            if (overview.active != null) const SizedBox(height: 16),
            if (overview.next != null)
              _NextCard(next: overview.next!, l10n: l10n),
            const SizedBox(height: 24),
            Text(
              l10n.seasonsTitle,
              style: const TextStyle(
                  fontFamily: kSerif,
                  color: AppColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            for (final s in majorFasts)
              _FastListTile(season: s, label: seasonLabel(s, l10n)),
          ],
        ),
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.active, required this.l10n});

  final ActiveFast active;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final progress = active.dayOfSeason / active.totalDays;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(seasonLabel(active.season, l10n),
              style: const TextStyle(
                  fontFamily: kSerif,
                  color: AppColors.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(l10n.seasonDayOfTotal(active.dayOfSeason, active.totalDays),
              style: const TextStyle(color: AppColors.inkMuted, fontSize: 14)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.next, required this.l10n});

  final UpcomingFast next;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${next.daysUntil}',
                  style: const TextStyle(
                      fontFamily: kSerif,
                      color: AppColors.gold,
                      fontSize: 44,
                      height: 1,
                      fontWeight: FontWeight.w600)),
              Text(l10n.daysUnit,
                  style: const TextStyle(
                      color: AppColors.inkMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.nextFastLabel(seasonLabel(next.season, l10n)),
                    style: const TextStyle(
                        fontFamily: kSerif,
                        color: AppColors.ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                    l10n.beginsOn(DateFormat.yMMMMd(
                            Localizations.localeOf(context).toString())
                        .format(next.start)),
                    style: const TextStyle(
                        color: AppColors.inkMuted, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FastListTile extends StatelessWidget {
  const _FastListTile({required this.season, required this.label});

  final FastSeason season;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_florist_outlined,
              color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontFamily: kSerif,
                  color: AppColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
