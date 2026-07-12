# Validation harness — engine vs. orthocal.info

The rule engine in `lib/core/` must be **provably** correct: showing a wrong
fasting day is this app's #1 cause-of-death (see `CLAUDE.md`). This directory
holds the automated day-by-day comparison against
[orthocal.info](https://orthocal.info) (the OCA typikon, MIT-licensed source
`orthocal-python`), covering **2020–2033**.

## How it works (offline-first, API-respectful)

1. **Refresh (occasional, networked, manual):**
   ```
   dart run tool/refresh_orthocal_snapshot.dart --start 2020 --end 2033
   ```
   Pulls each day from the orthocal.info API and writes a compact snapshot to
   `test/validation/snapshots/orthocal_YYYY.json`. Run rarely and politely
   (the script rate-limits itself). The snapshots are **committed to the repo**.

2. **Compare (fast, offline, every CI run):**
   ```
   flutter test test/validation
   ```
   `orthocal_comparison_test.dart` reads the committed snapshots — **no
   network** — and runs `computeFastingDay` for every day, mapping our
   `FastLevel` to orthocal's rendered permission and reporting every mismatch.

We do **not** call the API at app runtime (architecture principle #1:
local-first). It is a test-time oracle only.

## Interpreting mismatches

The mapping between orthocal's `(fast_level, fast_exception)` and our
`FastLevel` is best-effort and documented inline in the test. A mismatch means
one of:

- **An engine bug** — fix `lib/core/fasting_rules.dart`.
- **A jurisdiction/typikon nuance** orthocal encodes that we deliberately
  simplify in v1 — add the date to the `knownDifferences` allow-list in the
  test with a comment explaining why.

The goal is an **empty mismatch report** (or an explicitly-justified
allow-list) before the engine is considered done (Faz 0 exit criterion).

## Status

- [x] Harness + snapshot format + comparison test scaffolded.
- [ ] First snapshot pull (needs Dart SDK + network on the dev machine).
- [ ] Drive mismatches to zero / justified allow-list.
