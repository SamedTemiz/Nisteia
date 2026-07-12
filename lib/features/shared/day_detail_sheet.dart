import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../today/day_saints.dart';
import '../today/day_title.dart';
import '../today/level_style.dart';

/// Bottom sheet with the full verdict for a single day: level, reason, allowed
/// foods and saints. Shared by the Calendar (tap a day) and other screens.
void showDayDetailSheet(BuildContext context, DayInfo day) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _DayDetail(day: day),
  );
}

class _DayDetail extends StatelessWidget {
  const _DayDetail({required this.day});

  final DayInfo day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = colorForLevel(day.level);
    final saints = saintsForDay(day);
    final foods = day.allowed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMMMMEEEEd('en').format(day.date),
            style: const TextStyle(color: AppColors.inkMuted, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  levelLabel(day.level, l10n),
                  style: const TextStyle(
                    fontFamily: kSerif,
                    color: AppColors.gold,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            resolveDayTitle(day.titleKey, l10n),
            style: const TextStyle(color: AppColors.inkMuted, fontSize: 14),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FoodChip(label: l10n.foodMeat, ok: foods.meat),
              _FoodChip(label: l10n.foodDairy, ok: foods.dairy),
              _FoodChip(label: l10n.foodFish, ok: foods.fish),
              _FoodChip(label: l10n.foodWine, ok: foods.wine),
              _FoodChip(label: l10n.foodOil, ok: foods.oil),
            ],
          ),
          if (saints.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              l10n.saintsOfTheDay,
              style: const TextStyle(
                fontFamily: kSerif,
                color: AppColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...saints.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('•  $s',
                      style: const TextStyle(
                          color: AppColors.ink, fontSize: 14, height: 1.35)),
                )),
          ],
        ],
      ),
    );
  }
}

class _FoodChip extends StatelessWidget {
  const _FoodChip({required this.label, required this.ok});

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    const okColor = Color(0xFF3DA35C);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inkMuted.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ok ? Icons.check : Icons.close,
              size: 15, color: ok ? okColor : AppColors.inkMuted),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: ok ? AppColors.ink : AppColors.inkMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
