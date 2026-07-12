import 'package:flutter/material.dart';

import '../../core/models.dart';
import '../../l10n/generated/app_localizations.dart';

/// Color coding fixed by docs/screens.md — consistent across every screen.
/// Refined Byzantine palette (design-refs/calendar_nisteia_final): reads on the
/// dark aubergine background while keeping the five-level meaning.
Color colorForLevel(FastLevel level) {
  switch (level) {
    case FastLevel.strict:
      return const Color(0xFF8E2B2B); // 🟥 deep red
    case FastLevel.wineOil:
      return const Color(0xFF7C6A33); // 🟧 olive/bronze
    case FastLevel.fishWineOil:
      return const Color(0xFFC9A24B); // 🟨 gold
    case FastLevel.dairyAllowed:
      return const Color(0xFF3E5C86); // 🟦 muted blue (cheesefare)
    case FastLevel.fastFree:
      return const Color(0xFF2E5A3A); // 🟩 deep green
  }
}

String levelLabel(FastLevel level, AppLocalizations l10n) {
  switch (level) {
    case FastLevel.strict:
      return l10n.levelStrict;
    case FastLevel.wineOil:
      return l10n.levelWineOil;
    case FastLevel.fishWineOil:
      return l10n.levelFishWineOil;
    case FastLevel.dairyAllowed:
      return l10n.levelDairyAllowed;
    case FastLevel.fastFree:
      return l10n.levelFastFree;
  }
}
