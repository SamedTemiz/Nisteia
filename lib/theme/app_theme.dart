import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Central brand palette and theme. One source of truth so every screen reads
/// the same colors and type. (Per-fast-level colors live in
/// features/today/level_style.dart, shared across screens.)
abstract final class AppColors {
  /// Deep aubergine app background.
  static const background = Color(0xFF16121C);

  /// Lifted surface for cards, one step above the background.
  static const surface = Color(0xFF272230);

  /// Byzantine gold — the single accent color.
  static const gold = Color(0xFFC9A24B);

  /// Warm off-white for primary text.
  static const ink = Color(0xFFEDE7DA);

  /// Muted parchment for secondary text.
  static const inkMuted = Color(0xFF9A9186);
}

/// The brand serif, bundled as an asset (see pubspec.yaml).
const String kSerif = 'EBGaramond';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
      surface: AppColors.surface,
    ).copyWith(
      primary: AppColors.gold,
      onSurface: AppColors.ink,
    ),
    // Material-motion shared-axis for pushed routes (Settings, detail pages):
    // content slides subtly along the horizontal axis while cross-fading.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.horizontal),
        TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.horizontal),
        TargetPlatform.macOS: SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.horizontal),
        TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.horizontal),
        TargetPlatform.linux: SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.horizontal),
      },
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      // Display & headline: the brand serif, gold-friendly.
      displayLarge: base.textTheme.displayLarge
          ?.copyWith(fontFamily: kSerif, color: AppColors.ink),
      displayMedium: base.textTheme.displayMedium
          ?.copyWith(fontFamily: kSerif, color: AppColors.ink),
      headlineLarge: base.textTheme.headlineLarge
          ?.copyWith(fontFamily: kSerif, color: AppColors.ink),
      headlineMedium: base.textTheme.headlineMedium
          ?.copyWith(fontFamily: kSerif, color: AppColors.ink),
      titleLarge: base.textTheme.titleLarge
          ?.copyWith(fontFamily: kSerif, color: AppColors.ink),
    ),
  );
}

/// Uppercase, letter-spaced gold label used for section eyebrows
/// ("TODAY", "FASTING LEVEL", "SAINTS OF THE DAY").
TextStyle eyebrowStyle(BuildContext context) => const TextStyle(
      color: AppColors.gold,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    );
