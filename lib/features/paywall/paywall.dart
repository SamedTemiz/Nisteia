import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'purchase_service.dart';

/// The one-time Pro purchase screen. Presented as a sheet when a Pro-gated
/// action is attempted (unlimited calendar, meal planner, widgets…).
///
/// Purchases go straight through Google Play Billing (`in_app_purchase`);
/// the "No subscription" messaging is itself the marketing hook
/// (docs/screens.md §7).
void showPaywall(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const _Paywall(),
  );
}

class _Paywall extends ConsumerWidget {
  const _Paywall();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Close automatically the moment the purchase lands.
    ref.listen(proProvider, (_, isPro) {
      if (isPro && context.mounted) Navigator.of(context).pop();
    });
    final features = [
      l10n.proFeatCalendar,
      l10n.proFeatWidgets,
      l10n.proFeatMeals,
      l10n.proFeatNotifs,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.workspace_premium_outlined,
              color: AppColors.gold, size: 44),
          const SizedBox(height: 12),
          Text(
            l10n.settingsProStatus,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: kSerif,
              color: AppColors.gold,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.gold, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(f,
                          style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 15,
                              height: 1.35)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final launched = await ref.read(proProvider.notifier).buy();
              if (!launched && context.mounted) {
                // Store unreachable (emulator/web) or product not configured.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.purchasesLater)),
                );
                Navigator.of(context).pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(l10n.proUnlock,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.proNoSubscription,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.inkMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
