import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:nepali_patro_lite/models/patro_date.dart';
import 'package:nepali_patro_lite/services/calendar_repository.dart';
import 'package:nepali_patro_lite/services/calendar_update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('repository loads updated cached JSON before bundled assets', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final calendarJson = File(
      'assets/data/calendar/2083.json',
    ).readAsStringSync();
    final holidaysJson = File(
      'assets/data/holidays/2083_holidays.json',
    ).readAsStringSync();
    await CalendarRepository.saveCache(
      preferences: prefs,
      version: const CalendarDataVersion(
        version: '2083.2.0',
        supportedYears: [2083],
        lastVerified: '2026-05-28',
        lastUpdated: '2026-05-29',
        source: 'Manual verified',
      ),
      calendarJsonByYear: {2083: calendarJson},
      holidaysJsonByYear: {2083: holidaysJson},
    );

    final repository = await CalendarRepository.load(preferences: prefs);

    expect(repository.loadedFromCache, isTrue);
    expect(repository.version.version, '2083.2.0');
  });

  test('invalid downloaded update is rejected and old cache remains', () async {
    SharedPreferences.setMockInitialValues({
      CalendarRepository.cachedVersionKey: jsonEncode({
        'version': '2083.1.0',
        'supported_years': [2083],
        'last_verified': '2026-05-28',
        'last_updated': '2026-05-28',
        'source': 'Manual verified',
      }),
      '${CalendarRepository.cachedCalendarPrefix}2083': File(
        'assets/data/calendar/2083.json',
      ).readAsStringSync(),
      '${CalendarRepository.cachedHolidaysPrefix}2083': File(
        'assets/data/holidays/2083_holidays.json',
      ).readAsStringSync(),
    });
    final prefs = await SharedPreferences.getInstance();
    final invalidCalendar =
        jsonDecode(File('assets/data/calendar/2083.json').readAsStringSync())
            as List<dynamic>;
    invalidCalendar.add(invalidCalendar.first);
    final client = MockClient((request) async {
      if (request.url.path.endsWith('calendar_version.json')) {
        return Response(
          jsonEncode({
            'version': '2083.2.0',
            'supported_years': [2083],
            'calendar_url': 'https://example.com/calendar_2083.json',
            'holidays_url': 'https://example.com/holidays_2083.json',
            'last_verified': '2026-05-28',
            'source': 'Manual verified',
          }),
          200,
        );
      }
      if (request.url.path.endsWith('calendar_2083.json')) {
        return Response(jsonEncode(invalidCalendar), 200);
      }
      return Response('[]', 200);
    });

    final result =
        await CalendarUpdateService(
          client: client,
          preferences: prefs,
        ).checkForUpdate(
          currentVersion: CalendarDataVersion.fromJson(
            jsonDecode(prefs.getString(CalendarRepository.cachedVersionKey)!)
                as Map<String, dynamic>,
          ),
          hasInternet: () async => true,
        );

    expect(result.status, CalendarUpdateStatus.failed);
    final savedVersion = CalendarDataVersion.fromJson(
      jsonDecode(prefs.getString(CalendarRepository.cachedVersionKey)!)
          as Map<String, dynamic>,
    );
    expect(savedVersion.version, '2083.1.0');
  });
}
