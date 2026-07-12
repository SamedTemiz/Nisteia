import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/settings.dart';
import '../../core/fasting_rules.dart';
import '../../core/models.dart';

/// Today's fasting verdict, in the user's chosen calendar mode.
final todayProvider = Provider<DayInfo>((ref) {
  final calendar = ref.watch(settingsProvider.select((s) => s.calendar));
  return computeFastingDay(DateTime.now(), calendar: calendar);
});
