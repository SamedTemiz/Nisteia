import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../today/level_style.dart';
import '../today/today_providers.dart';

/// "What can I eat?" — resolves today's level into concrete allowed/avoided
/// food categories, and teaches the shellfish nuance that trips up converts
/// (docs/screens.md §5).
class GuideScreen extends ConsumerWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final day = ref.watch(todayProvider);
    final a = day.allowed;

    // Category → allowed today. Shellfish and honey are permitted at every
    // level (no backbone / not an animal food); eggs track dairy.
    final items = <(String, bool)>[
      (l10n.foodMeat, a.meat),
      (l10n.foodDairy, a.dairy),
      (l10n.foodEggs, a.dairy),
      (l10n.foodFish, a.fish),
      (l10n.foodShellfish, true),
      (l10n.foodOil, a.oil),
      (l10n.foodWine, a.wine),
      (l10n.foodHoney, true),
    ];
    final allowed = [
      for (final it in items)
        if (it.$2) it.$1
    ];
    final avoided = [
      for (final it in items)
        if (!it.$2) it.$1
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(l10n.guideTitle,
            style: const TextStyle(
                fontFamily: kSerif, color: AppColors.gold, fontSize: 22)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _LevelBanner(day: day, l10n: l10n),
            const SizedBox(height: 20),
            _FoodList(
              title: l10n.foodAllowed,
              items: allowed,
              allowed: true,
            ),
            const SizedBox(height: 16),
            _FoodList(
              title: l10n.foodAvoided,
              items: avoided,
              allowed: false,
            ),
            const SizedBox(height: 20),
            _ShellfishNote(text: l10n.shellfishNote),
          ],
        ),
      ),
    );
  }
}

class _LevelBanner extends StatelessWidget {
  const _LevelBanner({required this.day, required this.l10n});

  final DayInfo day;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = colorForLevel(day.level);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(levelLabel(day.level, l10n),
              style: const TextStyle(
                  fontFamily: kSerif,
                  color: AppColors.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FoodList extends StatelessWidget {
  const _FoodList(
      {required this.title, required this.items, required this.allowed});

  final String title;
  final List<String> items;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    const okColor = Color(0xFF3DA35C);
    final accent = allowed ? okColor : const Color(0xFF8E2B2B);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(allowed ? Icons.check_circle : Icons.cancel,
                  color: accent, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontFamily: kSerif,
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('—', style: TextStyle(color: AppColors.inkMuted)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final it in items)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(it,
                          style: const TextStyle(
                              color: AppColors.ink, fontSize: 14)),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ShellfishNote extends StatelessWidget {
  const _ShellfishNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.ink, fontSize: 14, height: 1.45)),
          ),
        ],
      ),
    );
  }
}
