import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nisteia/core/fasting_rules.dart';
import 'package:nisteia/core/models.dart';

/// Offline comparison of our engine against committed orthocal.info snapshots.
///
/// Skips cleanly when snapshots are absent (they are pulled with
/// `tool/refresh_orthocal_snapshot.dart` — see test/validation/README.md).
void main() {
  final dir = Directory('test/validation/snapshots');
  final snapshots = dir.existsSync()
      ? dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
      : <File>[];

  if (snapshots.isEmpty) {
    test('engine matches orthocal.info across all snapshot days', () {},
        skip: 'No snapshots yet — run tool/refresh_orthocal_snapshot.dart. '
            'See test/validation/README.md.');
    return;
  }

  test('engine matches orthocal.info across all snapshot days', () {
    final mismatches = <String>[];
    var compared = 0;

    for (final file in snapshots) {
      final year =
          int.parse(RegExp(r'(\d{4})').firstMatch(file.path)!.group(1)!);
      final byDay = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      byDay.forEach((key, value) {
        final parts = key.split('-');
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final date = DateTime(year, month, day);
        final iso = date.toIso8601String().substring(0, 10);
        if (_knownDifferences.contains(iso)) return;

        final o = value as Map<String, dynamic>;
        final expected = _mapOrthocalToLevel(
          (o['fast_level_desc'] as String?) ?? '',
          (o['fast_exception_desc'] as String?) ?? '',
        );

        final actual = computeFastingDay(date).level;
        compared++;
        if (actual != expected) {
          mismatches.add('$iso  ours=${actual.name}  '
              'orthocal=${expected.name}  '
              '["${o['fast_level_desc']}" / "${o['fast_exception_desc']}"]');
        }
      });
    }

    if (mismatches.isNotEmpty) {
      // Print a bounded, readable report to guide engine refinement.
      final shown = mismatches.take(60).join('\n');
      fail('Compared $compared days; ${mismatches.length} mismatch(es):\n'
          '$shown${mismatches.length > 60 ? '\n... (${mismatches.length - 60} more)' : ''}');
    }
  });
}

/// Dates where our v1 engine intentionally differs from orthocal's typikon.
/// Each entry MUST carry a comment justifying the divergence.
const Set<String> _knownDifferences = {
  // (empty for now — populate as jurisdiction nuances are triaged)
};

/// Best-effort translation of orthocal's rendered fasting text to our
/// [FastLevel]. Intentionally simple; refine alongside the engine.
FastLevel _mapOrthocalToLevel(String levelDesc, String exceptionDesc) {
  final s = '${levelDesc.toLowerCase()} | ${exceptionDesc.toLowerCase()}';

  if (s.contains('no fast') ||
      s.contains('fast free') ||
      s.contains('fast-free')) {
    return FastLevel.fastFree;
  }
  // Cheesefare/"Maslenitsa" week: orthocal labels it "Meat Fast" — abstain from
  // meat only, dairy/eggs/fish still permitted. Maps to our dairy-allowed level.
  if (s.contains('dairy') ||
      s.contains('cheese') ||
      s.contains('milk') ||
      s.contains('meat fast')) {
    return FastLevel.dairyAllowed;
  }
  if (s.contains('fish') && !s.contains('no fish')) {
    return FastLevel.fishWineOil;
  }
  if (s.contains('wine') || s.contains('oil')) {
    return FastLevel.wineOil;
  }
  if (levelDesc.trim().isEmpty) {
    return FastLevel.fastFree;
  }
  return FastLevel.strict;
}
