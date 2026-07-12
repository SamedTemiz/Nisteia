import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';

/// Dedicated data-sources & attribution screen (rule transparency is a trust
/// pillar — docs/market-analysis "kaynak şeffaflığı"). Reached from the
/// navigation drawer and Settings.
class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = <(IconData, String, String)>[
      (Icons.menu_book_outlined, l10n.sourcesEngineTitle, l10n.sourcesEngineBody),
      (Icons.brightness_5_outlined, l10n.sourcesPaschaTitle, l10n.sourcesPaschaBody),
      (Icons.auto_awesome_outlined, l10n.sourcesSaintsTitle, l10n.sourcesSaintsBody),
      (Icons.text_fields_outlined, l10n.sourcesFontTitle, l10n.sourcesFontBody),
      (Icons.lock_outline, l10n.sourcesPrivacyTitle, l10n.sourcesPrivacyBody),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.sourcesTitle,
            style: const TextStyle(
                fontFamily: kSerif, color: AppColors.gold, fontSize: 22)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            for (final (icon, title, body) in entries)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                        Icon(icon, color: AppColors.gold, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontFamily: kSerif,
                                  color: AppColors.gold,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(body,
                        style: const TextStyle(
                            color: AppColors.ink, fontSize: 14, height: 1.5)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(l10n.disclaimer,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.inkMuted, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
