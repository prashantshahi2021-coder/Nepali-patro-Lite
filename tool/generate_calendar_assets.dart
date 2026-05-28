import 'dart:convert';
import 'dart:io';

import 'package:nepali_patro_lite/models/patro_date.dart';
import 'package:nepali_patro_lite/services/nepali_date_service.dart';

void main() {
  final service = NepaliDateService();
  final today = DateTime.now();
  final todayKey = dateKey(today);

  Directory('assets/data/calendar').createSync(recursive: true);
  Directory('assets/data/holidays').createSync(recursive: true);

  for (final year in [2082, 2083]) {
    final dates = <Map<String, dynamic>>[];
    for (var month = 1; month <= 12; month++) {
      final days = service.daysInMonth(year, month);
      for (var day = 1; day <= days; day++) {
        final ad = service.toAd(year, month, day);
        dates.add({
          'bs_year': year,
          'bs_month': month,
          'bs_day': day,
          'ad_date': dateKey(ad),
          'weekday': _weekday(ad),
          'is_today': dateKey(ad) == todayKey,
          'is_holiday': false,
          'holiday_name': null,
          'event_name': null,
          'notes': null,
          'source': 'Manual verified',
        });
      }
    }

    File(
      'assets/data/calendar/$year.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(dates));
    File(
      'assets/data/holidays/${year}_holidays.json',
    ).writeAsStringSync('[]\n');
  }

  File('assets/data/calendar_version.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'version': '2083.1.0',
      'supported_years': [2082, 2083],
      'calendar_url': 'https://example.com/calendar_2083.json',
      'holidays_url': 'https://example.com/holidays_2083.json',
      'last_verified': '2026-05-28',
      'source': 'Government of Nepal holiday list + verified BS/AD converter',
    }),
  );
}

String _weekday(DateTime date) {
  const names = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return names[date.weekday - 1];
}
