import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/settings.dart';
import '../../core/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../onboarding/option_card.dart';
import '../paywall/paywall.dart';
import '../paywall/purchase_service.dart';
import 'sources_screen.dart';

/// Selectable app languages: null = follow the system. Native names on
/// purpose — a user stuck in the wrong language must still recognise theirs.
const _languages = <(String?, String)>[
  (null, ''), // placeholder; label resolved via l10n.languageSystem
  ('en', 'English'),
  ('el', 'Ελληνικά'),
  ('ro', 'Română'),
  ('ru', 'Русский'),
  ('sr', 'Српски'),
  ('bg', 'Български'),
];

/// Settings: calendar & practice, notifications, Pro, sources & disclaimer,
/// and a rule-error report path (docs/screens.md §6).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.settingsTitle,
            style: const TextStyle(
                fontFamily: kSerif, color: AppColors.gold, fontSize: 22)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _Section(l10n.settingsSectionCalendar),
            OptionCard(
              title: l10n.calendarNew,
              subtitle: l10n.calendarNewSubtitle,
              selected: settings.calendar == Calendar.newCalendar,
              onTap: () => controller.setCalendar(Calendar.newCalendar),
            ),
            OptionCard(
              title: l10n.calendarOld,
              subtitle: l10n.calendarOldSubtitle,
              selected: settings.calendar == Calendar.oldCalendar,
              onTap: () => controller.setCalendar(Calendar.oldCalendar),
            ),
            const SizedBox(height: 8),
            OptionCard(
              title: l10n.strictnessCommon,
              subtitle: l10n.strictnessCommonSubtitle,
              selected: settings.strictness == Strictness.common,
              onTap: () => controller.setStrictness(Strictness.common),
            ),
            OptionCard(
              title: l10n.strictnessMonastic,
              subtitle: l10n.strictnessMonasticSubtitle,
              selected: settings.strictness == Strictness.monastic,
              onTap: () => controller.setStrictness(Strictness.monastic),
            ),
            const SizedBox(height: 8),
            _TapRow(
              icon: Icons.translate,
              label:
                  '${l10n.language} · ${_languageLabel(settings.localeCode, l10n)}',
              onTap: () => _pickLanguage(context, l10n, settings.localeCode,
                  controller.setLocale),
            ),
            const SizedBox(height: 24),
            _Section(l10n.settingsSectionNotifications),
            _SwitchRow(
              label: l10n.settingsEveningReminder,
              value: settings.eveningReminder,
              onChanged: controller.setEveningReminder,
            ),
            _SwitchRow(
              label: l10n.settingsSeasonAlerts,
              value: settings.seasonAlerts,
              onChanged: controller.setSeasonAlerts,
            ),
            const SizedBox(height: 24),
            _Section(l10n.settingsProStatus),
            if (ref.watch(proProvider))
              _Card(
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium,
                        color: AppColors.gold, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l10n.proThanks,
                          style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 14,
                              height: 1.4)),
                    ),
                  ],
                ),
              )
            else ...[
              _TapRow(
                icon: Icons.workspace_premium_outlined,
                label: l10n.proUnlock,
                onTap: () => showPaywall(context),
              ),
              _TapRow(
                icon: Icons.restore,
                label: l10n.settingsRestore,
                onTap: () async {
                  final ok =
                      await ref.read(proProvider.notifier).restore();
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.purchasesLater)),
                    );
                  }
                },
              ),
            ],
            const SizedBox(height: 24),
            _Section(l10n.settingsSectionAbout),
            _Card(
                child: Text(l10n.settingsSourcesBody,
                    style: const TextStyle(
                        color: AppColors.ink, fontSize: 14, height: 1.5))),
            const SizedBox(height: 10),
            _Card(
                child: Text(l10n.disclaimer,
                    style: const TextStyle(
                        color: AppColors.inkMuted, fontSize: 13, height: 1.5))),
            const SizedBox(height: 10),
            _TapRow(
              icon: Icons.menu_book_outlined,
              label: l10n.sourcesTitle,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SourcesScreen()),
              ),
            ),
            _TapRow(
              icon: Icons.bug_report_outlined,
              label: l10n.settingsReportError,
              onTap: () => _reportError(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the user's mail app with a pre-filled rule-error report; falls
  /// back to a dialog with the address when no mail handler is available.
  Future<void> _reportError(BuildContext context, AppLocalizations l10n) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'hello@nisteia.app',
      query: 'subject=${Uri.encodeComponent(l10n.settingsReportSubject)}',
    );
    var launched = false;
    try {
      launched = await launchUrl(uri);
    } catch (_) {
      launched = false;
    }
    if (!launched && context.mounted) {
      _showReportDialog(context, l10n);
    }
  }

  void _showReportDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.settingsReportError,
            style: const TextStyle(color: AppColors.ink)),
        content: Text(
          l10n.reportErrorBody,
          style: const TextStyle(color: AppColors.inkMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok, style: const TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }
}

String _languageLabel(String? code, AppLocalizations l10n) {
  if (code == null) return l10n.languageSystem;
  for (final (c, name) in _languages) {
    if (c == code) return name;
  }
  return code;
}

Future<void> _pickLanguage(
  BuildContext context,
  AppLocalizations l10n,
  String? current,
  Future<void> Function(String?) onPick,
) async {
  final chosen = await showDialog<(String?,)>(
    context: context,
    builder: (context) => SimpleDialog(
      backgroundColor: AppColors.surface,
      title: Text(l10n.language,
          style: const TextStyle(color: AppColors.ink, fontFamily: kSerif)),
      children: [
        for (final (code, name) in _languages)
          RadioListTile<String?>(
            value: code,
            // ignore: deprecated_member_use
            groupValue: current,
            activeColor: AppColors.gold,
            title: Text(code == null ? l10n.languageSystem : name,
                style: const TextStyle(color: AppColors.ink)),
            // ignore: deprecated_member_use
            onChanged: (_) => Navigator.of(context).pop((code,)),
          ),
      ],
    ),
  );
  if (chosen != null) await onPick(chosen.$1);
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(title.toUpperCase(),
            style: const TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow(
      {required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.gold,
              title: Text(label,
                  style: const TextStyle(color: AppColors.ink, fontSize: 15)),
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
      );
}

class _TapRow extends StatelessWidget {
  const _TapRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: Icon(icon, color: AppColors.gold),
            title: Text(label,
                style: const TextStyle(color: AppColors.ink, fontSize: 15)),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.inkMuted),
            onTap: onTap,
          ),
        ),
      );
}
