import 'package:flutter/material.dart';

import '../features/calendar/calendar_screen.dart';
import '../features/guide/guide_screen.dart';
import '../features/seasons/seasons_screen.dart';
import '../features/today/today_screen.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

/// The main navigation shell: four primary tabs. Settings is reached from the
/// Today screen's app bar, not a tab (per docs/screens.md).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    TodayScreen(),
    CalendarScreen(),
    SeasonsScreen(),
    GuideScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: _FadeThroughIndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.gold.withValues(alpha: 0.22),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.wb_sunny_outlined),
            selectedIcon: const Icon(Icons.wb_sunny, color: AppColors.gold),
            label: l10n.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon:
                const Icon(Icons.calendar_month, color: AppColors.gold),
            label: l10n.navCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.landscape_outlined),
            selectedIcon: const Icon(Icons.landscape, color: AppColors.gold),
            label: l10n.navSeasons,
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu_outlined),
            selectedIcon:
                const Icon(Icons.restaurant_menu, color: AppColors.gold),
            label: l10n.navGuide,
          ),
        ],
      ),
    );
  }
}

/// An [IndexedStack] whose visible child changes with a Material fade-through
/// motion (fade out fast, fade in with a gentle upward drift + scale). Unlike
/// `PageTransitionSwitcher`, all children stay alive so tab state (calendar
/// month, scroll positions) survives switching.
class _FadeThroughIndexedStack extends StatefulWidget {
  const _FadeThroughIndexedStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_FadeThroughIndexedStack> createState() =>
      _FadeThroughIndexedStackState();
}

class _FadeThroughIndexedStackState extends State<_FadeThroughIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: 1,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    // Incoming content appears in the second two-thirds (fade-through spec).
    curve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _scale =
      Tween<double>(begin: 0.98, end: 1).animate(_fade);

  late final Animation<Offset> _drift = Tween<Offset>(
    begin: const Offset(0, 0.012),
    end: Offset.zero,
  ).animate(_fade);

  @override
  void didUpdateWidget(covariant _FadeThroughIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _drift,
        child: ScaleTransition(
          scale: _scale,
          child: IndexedStack(index: widget.index, children: widget.children),
        ),
      ),
    );
  }
}
