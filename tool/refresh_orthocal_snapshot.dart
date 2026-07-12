/// Dev-only tool: pull fasting data from the orthocal.info API into committed
/// snapshot files used by `test/validation`. NEVER imported by the app.
///
/// Usage:
///   dart run tool/refresh_orthocal_snapshot.dart [--start 2020] [--end 2033]
///
/// Writes test/validation/snapshots/orthocal_YYYY.json for each year.
/// Self-rate-limits (be a polite guest of a free community service).
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  var start = 2020;
  var end = 2033;
  for (var i = 0; i < args.length - 1; i++) {
    if (args[i] == '--start') start = int.parse(args[i + 1]);
    if (args[i] == '--end') end = int.parse(args[i + 1]);
  }

  final outDir = Directory('test/validation/snapshots');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  final client = http.Client();
  try {
    for (var year = start; year <= end; year++) {
      stdout.writeln('Fetching $year ...');
      final byDay = <String, dynamic>{};
      var day = DateTime(year, 1, 1);
      while (day.year == year) {
        final url = Uri.parse(
            'https://orthocal.info/api/gregorian/${day.year}/${day.month}/${day.day}/');
        final resp = await client.get(url);
        if (resp.statusCode != 200) {
          stderr
              .writeln('  ${day.toIso8601String()} -> HTTP ${resp.statusCode}');
          day = day.add(const Duration(days: 1));
          continue;
        }
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        byDay['${day.month}-${day.day}'] = {
          'fast_level': json['fast_level'],
          'fast_level_desc': json['fast_level_desc'],
          'fast_exception': json['fast_exception'],
          'fast_exception_desc': json['fast_exception_desc'],
        };
        day = day.add(const Duration(days: 1));
        // Politeness: ~5 req/s.
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      final file = File('${outDir.path}/orthocal_$year.json');
      file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(byDay));
      stdout.writeln('  wrote ${file.path} (${byDay.length} days)');
    }
  } finally {
    client.close();
  }
  stdout.writeln('Done.');
}
