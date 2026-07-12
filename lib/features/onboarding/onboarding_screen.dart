import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/settings.dart';
import '../../core/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'option_card.dart';

/// First-run onboarding: calendar, strictness, notifications. Writes the chosen
/// preferences and flips [AppSettings.onboardingComplete] on finish.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  Calendar _calendar = Calendar.newCalendar;
  Strictness _strictness = Strictness.common;

  static const _steps = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _steps - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) {
      _controller.previousPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  Future<void> _finish() async {
    final controller = ref.read(settingsProvider.notifier);
    await controller.setCalendar(_calendar);
    await controller.setStrictness(_strictness);
    await controller.completeOnboarding();
    // _RootGate rebuilds to HomeShell once onboardingComplete flips.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              l10n.appTitle,
              style: const TextStyle(
                fontFamily: kSerif,
                color: AppColors.gold,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            _Dots(count: _steps, active: _page),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _CalendarStep(
                    selected: _calendar,
                    onSelect: (c) => setState(() => _calendar = c),
                  ),
                  _StrictnessStep(
                    selected: _strictness,
                    onSelect: (s) => setState(() => _strictness = s),
                  ),
                  const _NotifyStep(),
                ],
              ),
            ),
            _NavBar(
              page: _page,
              steps: _steps,
              onBack: _back,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarStep extends StatelessWidget {
  const _CalendarStep({required this.selected, required this.onSelect});

  final Calendar selected;
  final ValueChanged<Calendar> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _StepBody(
      title: l10n.onboardingCalendarStep,
      children: [
        OptionCard(
          title: l10n.calendarNew,
          subtitle: l10n.calendarNewSubtitle,
          selected: selected == Calendar.newCalendar,
          onTap: () => onSelect(Calendar.newCalendar),
        ),
        OptionCard(
          title: l10n.calendarOld,
          subtitle: l10n.calendarOldSubtitle,
          selected: selected == Calendar.oldCalendar,
          onTap: () => onSelect(Calendar.oldCalendar),
        ),
        const SizedBox(height: 8),
        _Helper(l10n.calendarHelper),
      ],
    );
  }
}

class _StrictnessStep extends StatelessWidget {
  const _StrictnessStep({required this.selected, required this.onSelect});

  final Strictness selected;
  final ValueChanged<Strictness> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _StepBody(
      title: l10n.onboardingStrictnessStep,
      children: [
        OptionCard(
          title: l10n.strictnessCommon,
          subtitle: l10n.strictnessCommonSubtitle,
          selected: selected == Strictness.common,
          onTap: () => onSelect(Strictness.common),
        ),
        OptionCard(
          title: l10n.strictnessMonastic,
          subtitle: l10n.strictnessMonasticSubtitle,
          selected: selected == Strictness.monastic,
          onTap: () => onSelect(Strictness.monastic),
        ),
        const SizedBox(height: 8),
        _Helper(l10n.strictnessNote),
        const SizedBox(height: 16),
        _Helper(l10n.disclaimer),
      ],
    );
  }
}

class _NotifyStep extends StatelessWidget {
  const _NotifyStep();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _StepBody(
      title: l10n.onboardingNotifyStep,
      children: [
        const SizedBox(height: 8),
        const Icon(Icons.notifications_active_outlined,
            color: AppColors.gold, size: 56),
        const SizedBox(height: 20),
        Text(
          l10n.onboardingNotifyBody,
          textAlign: TextAlign.center,
          style:
              const TextStyle(color: AppColors.ink, fontSize: 16, height: 1.5),
        ),
      ],
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: kSerif,
              color: AppColors.ink,
              fontSize: 24,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          ...children,
        ],
      ),
    );
  }
}

class _Helper extends StatelessWidget {
  const _Helper(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: AppColors.inkMuted, fontSize: 13, height: 1.45),
      );
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});
  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final on = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          width: on ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                on ? AppColors.gold : AppColors.inkMuted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.page,
    required this.steps,
    required this.onBack,
    required this.onNext,
  });

  final int page;
  final int steps;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLast = page == steps - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        children: [
          if (page > 0)
            TextButton(
              onPressed: onBack,
              child: Text(l10n.onboardingBack,
                  style: const TextStyle(color: AppColors.inkMuted)),
            ),
          const Spacer(),
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: const Color(0xFF16121C),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            child: Text(isLast ? l10n.onboardingFinish : l10n.onboardingNext,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
