import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_patro_lite/services/calendar_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'invalid cached calendar falls back to bundled data without crashing',
    () async {
      final calendar =
          jsonDecode(File('assets/data/calendar/2083.json').readAsStringSync())
              as List<dynamic>;
      calendar.add(calendar.first);
      SharedPreferences.setMockInitialValues({
        CalendarRepository.cachedVersionKey: jsonEncode({
          'version': '2083.9.0',
          'supported_years': [2083],
          'last_verified': '2026-05-28',
          'source': 'Manual verified',
        }),
        '${CalendarRepository.cachedCalendarPrefix}2083': jsonEncode(calendar),
        '${CalendarRepository.cachedHolidaysPrefix}2083': '[]',
      });

      final repository = await CalendarRepository.load(
        preferences: await SharedPreferences.getInstance(),
      );

      expect(repository.loadedFromCache, isFalse);
      expect(repository.hasValidationErrors, isFalse);
      expect(repository.fromAd(DateTime(2026, 5, 28)), isNotNull);
    },
  );

  test(
    'bad holiday records are ignored without dropping valid calendar data',
    () async {
      final calendar = File(
        'assets/data/calendar/2083.json',
      ).readAsStringSync();
      SharedPreferences.setMockInitialValues({
        CalendarRepository.cachedVersionKey: jsonEncode({
          'version': '2083.9.1',
          'supported_years': [2083],
          'last_verified': '2026-05-28',
          'source': 'Manual verified',
        }),
        '${CalendarRepository.cachedCalendarPrefix}2083': calendar,
        '${CalendarRepository.cachedHolidaysPrefix}2083': jsonEncode([
          {
            'bs_year': 2083,
            'bs_month': 13,
            'bs_day': 1,
            'holiday_name': 'Invalid',
            'type': 'Holiday',
            'source': 'Manual verified',
          },
        ]),
      });

      final repository = await CalendarRepository.load(
        preferences: await SharedPreferences.getInstance(),
      );

      expect(repository.holidays, isEmpty);
      expect(repository.fromBs(2083, 1, 1), isNotNull);
    },
  );
}
