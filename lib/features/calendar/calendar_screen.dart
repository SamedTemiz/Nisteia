import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/day_providers.dart';
import '../../core/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../paywall/paywall.dart';
import '../paywall/purchase_service.dart';
import '../shared/day_detail_sheet.dart';
import '../today/level_style.dart';

/// Month calendar: every day filled with its fast-level colour, feast days
/// starred, today ringed. Free tier shows the current and next month; going
/// further triggers the paywall (docs/screens.md §3).
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _anchor; // first day of the shown month

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _anchor = DateTime(now.year, now.month, 1);
  }

  DateTime get _freeStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  DateTime get _freeEnd {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 1); // current + next month
  }

  bool _isFree(DateTime monthAnchor) =>
      !monthAnchor.isBefore(_freeStart) && !monthAnchor.isAfter(_freeEnd);

  void _shift(int months) {
    final target = DateTime(_anchor.year, _anchor.month + months, 1);
    // Pro: unlimited navigation. Free: current + next month (docs/screens.md).
    if (!ref.read(proProvider) && !_isFree(target)) {
      showPaywall(context);
      return;
    }
    setState(() => _anchor = target);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(l10n.calendarTitle,
            style: const TextStyle(
                fontFamily: kSerif, color: AppColors.gold, fontSize: 22)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _MonthHeader(
              anchor: _anchor,
              onPrev: () => _shift(-1),
              onNext: () => _shift(1),
            ),
            Expanded(child: _MonthGrid(anchor: _anchor)),
            const _Legend(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader(
      {required this.anchor, required this.onPrev, required this.onNext});

  final DateTime anchor;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left, color: AppColors.ink),
          ),
          Text(
            DateFormat.yMMMM(Localizations.localeOf(context).toString())
                .format(anchor),
            style: const TextStyle(
                fontFamily: kSerif,
                color: AppColors.gold,
                fontSize: 26,
                fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({required this.anchor});

  final DateTime anchor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstWeekday = anchor.weekday % 7; // Sunday-first column of day 1
    final gridStart = anchor.subtract(Duration(days: firstWeekday));
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Sunday-first header, localized (grid below is Sunday-first).
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        DateFormat.E(
                                Localizations.localeOf(context).toString())
                            // 2023-01-01 was a Sunday.
                            .format(DateTime(2023, 1, 1 + i))
                            .toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.inkMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (var week = 0; week < 6; week++)
              Row(
                children: [
                  for (var d = 0; d < 7; d++)
                    Expanded(
                      child: _DayCell(
                        date: gridStart.add(Duration(days: week * 7 + d)),
                        inMonth:
                            gridStart.add(Duration(days: week * 7 + d)).month ==
                                anchor.month,
                        todayKey: todayKey,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell(
      {required this.date, required this.inMonth, required this.todayKey});

  final DateTime date;
  final bool inMonth;
  final DateTime todayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!inMonth) {
      return AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: Text('${date.day}',
              style: TextStyle(
                  color: AppColors.inkMuted.withValues(alpha: 0.4),
                  fontSize: 14)),
        ),
      );
    }

    final day = ref.watch(fastingDayProvider(date));
    final isToday = DateTime(date.year, date.month, date.day) == todayKey;
    final isFeast = day.reason == FastReason.feast;
    final fill = colorForLevel(day.level);
    // Free days blend into the surface (design: unfilled).
    final bg = day.level == FastLevel.fastFree
        ? AppColors.background.withValues(alpha: 0.35)
        : fill;

    final l10n = AppLocalizations.of(context)!;
    final semantic =
        '${DateFormat.MMMMd(Localizations.localeOf(context).toString()).format(date)}: '
        '${levelLabel(day.level, l10n)}'
        '${isFeast ? ', ${l10n.feastStar}' : ''}';

    return Padding(
      padding: const EdgeInsets.all(3),
      child: AspectRatio(
        aspectRatio: 1,
        child: Semantics(
          button: true,
          label: semantic,
          excludeSemantics: true,
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showDayDetailSheet(context, day),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isToday
                      ? Border.all(color: AppColors.gold, width: 2)
                      : null,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text('${date.day}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                    ),
                    if (isFeast)
                      const Positioned(
                        bottom: 3,
                        left: 0,
                        right: 0,
                        child: Icon(Icons.star, size: 9, color: AppColors.gold),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Widget dot(FastLevel level, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                  color: colorForLevel(level), shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 8,
        children: [
          dot(FastLevel.strict, l10n.levelStrict),
          dot(FastLevel.wineOil, l10n.levelWineOil),
          dot(FastLevel.fishWineOil, l10n.levelFishWineOil),
          dot(FastLevel.dairyAllowed, l10n.levelDairyAllowed),
          dot(FastLevel.fastFree, l10n.levelFastFree),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 13, color: AppColors.gold),
              const SizedBox(width: 4),
              Text(l10n.feastStar,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
