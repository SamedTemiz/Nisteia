# Nisteia — Orthodox Fasting Assistant

> _Nisteia_ (Νηστεία) — Greek for "fasting". A fasting-first, local-first mobile
> app that answers one question at a glance: **"What can I eat today?"**

Not a calendar app — a fasting life assistant. See [CLAUDE.md](CLAUDE.md) for the
product brief, [ROADMAP.md](ROADMAP.md) for phases, and [docs/](docs/) for the
market analysis, screen specs, and rule-engine design.

## Architecture

Local-first, serverless: every fasting verdict is computed on-device. No backend,
no account, no login.

```
lib/
  core/      Pure-Dart rule engine (no Flutter imports)
             paschalion · calendar_math · fasting_rules · models
  data/      Embedded constants, generated from orthocal-python (MIT)
             commemorations.dart · commemoration_names.dart
  app/       Cross-feature glue: settings (shared_preferences + Riverpod),
             home_shell (bottom nav), day_providers
  features/  today · calendar · seasons · guide · settings · onboarding
             · paywall · notifications · shared
  l10n/      ARB strings (English v1; every user-facing string is a key)
  theme/     Brand palette + EB Garamond serif
test/
  core/        Engine + notification-planner unit tests
  validation/  Day-by-day comparison against orthocal.info snapshots
```

### The rule engine

The heart of the app. A day's fasting verdict is the seasonal/weekly rule
(Great Lent, Apostles', Dormition, Nativity, Wed/Fri) combined with
commemoration relaxations (a saint's feast permitting fish or wine & oil),
faithfully ported from the MIT-licensed
[orthocal-python](https://github.com/brianglass/orthocal-python) which
implements the OCA typikon. Pascha is computed on-device (Meeus Julian
Paschalion). Both the New (Revised Julian) and Old (Julian) calendars are
supported.

**Validated day-by-day against orthocal.info across 2020–2033 (~5,100 days) with
zero mismatches.** Wrong fasting information is this app's one fatal failure
mode, so the engine is proven before any UI is trusted.

## Commands

```bash
flutter test                 # all tests (required after any engine change)
flutter test test/validation # offline comparison vs orthocal snapshots
flutter analyze              # lint / static analysis
flutter gen-l10n             # regenerate localizations after editing ARB
flutter run                  # run on a device / emulator / -d chrome

# Dev-only tooling (never shipped):
dart run tool/refresh_orthocal_snapshot.dart   # pull validation snapshots
dart run tool/gen_commemorations.dart          # regenerate the data tables
```

## Status

- **Faz 0 (rule engine): complete** — validated at zero mismatches over the full
  2020–2033 range.
- **Faz 1 (MVP UI): screens complete** — Today, Calendar, Seasons, Guide,
  Settings, Onboarding, and a Pro paywall, over shared preferences + navigation.
  `flutter analyze` clean; 65 tests green; release web build succeeds.
- **Remaining Faz 1 device integration:** `flutter_local_notifications`
  delivery (the planner logic is built and tested), the RevenueCat one-time Pro
  purchase, and a `url_launcher` mail link.

## Licensing notes

- Rule logic & data: ported from orthocal-python (MIT) with attribution.
- EB Garamond display font: SIL Open Font License 1.1
  (`assets/fonts/EBGaramond-OFL.txt`).
- Ponomar project is GPL — used only for manual cross-checking, never embedded.
- Saint/feast **names** are facts (no copyright); long biographies are out of
  scope for v1.
