import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_patro_lite/models/patro_date.dart';
import 'package:nepali_patro_lite/services/calendar_validation_service.dart';
import 'package:nepali_patro_lite/services/nepali_date_service.dart';

void main() {
  test('today AD to BS conversion round trips through converter', () {
    final service = NepaliDateService();
    final today = DateTime.now();
    final bs = service.fromAd(today);
    final ad = service.toAd(bs.year, bs.month, bs.day);

    expect(_ymd(ad), _ymd(today));
  });

  test('BS to AD conversion round trips through converter', () {
    final service = NepaliDateService();
    final ad = service.toAd(2083, 2, 15);
    final bs = service.fromAd(ad);

    expect((bs.year, bs.month, bs.day), (2083, 2, 15));
  });

  test('month length validation matches converter', () {
    final dates = _loadCalendar(2083);
    final result = CalendarValidationService(NepaliDateService()).validate(
      calendarsByYear: {2083: dates},
      holidaysByYear: const {2083: []},
    );

    expect(
      result.errors.where((error) => error.contains('Month day count')),
      isEmpty,
    );
  });

  test('holiday mapping validation requires a calendar date', () {
    final dates = _loadCalendar(2083);
    final result = CalendarValidationService(NepaliDateService()).validate(
      calendarsByYear: {2083: dates},
      holidaysByYear: const {
        2083: [
          HolidayItem(
            bsYear: 2083,
            month: 13,
            day: 1,
            title: 'Invalid holiday',
            type: 'Manual',
            source: 'Manual verified',
          ),
        ],
      },
    );

    expect(
      result.errors.any((error) => error.contains('Holiday date missing')),
      isTrue,
    );
  });

  test('official 2083 MoHA holidays convert and validate', () {
    final holidays = _loadHolidays(2083);
    final dates = _loadCalendar(2083);
    final service = NepaliDateService();
    final result = CalendarValidationService(service).validate(
      calendarsByYear: {2083: dates},
      holidaysByYear: {2083: holidays},
    );

    expect(result.errors, isEmpty);
    for (final holiday in holidays) {
      expect(holiday.verified, isTrue, reason: holiday.title);
      expect(
        holiday.source,
        'Government of Nepal, Ministry of Home Affairs',
        reason: holiday.title,
      );
      expect(holiday.sourceUrl, isNotEmpty, reason: holiday.title);
      expect(
        {'national', 'province', 'community', 'gender', 'office'},
        contains(holiday.type),
        reason: holiday.title,
      );
      expect(holiday.appliesTo, isNotEmpty, reason: holiday.title);
      expect(
        dateKey(service.toAd(holiday.bsYear, holiday.month, holiday.day)),
        dateKey(holiday.adDate!),
        reason: holiday.title,
      );
    }
  });

  test('duplicate date detection reports duplicate AD and BS dates', () {
    final dates = _loadCalendar(2083);
    final duplicate = dates.first;
    final result = CalendarValidationService(NepaliDateService()).validate(
      calendarsByYear: {
        2083: [duplicate, duplicate, ...dates.skip(1)],
      },
      holidaysByYear: const {2083: []},
    );

    expect(
      result.errors.any((error) => error.contains('Duplicate AD date')),
      isTrue,
    );
    expect(
      result.errors.any((error) => error.contains('Duplicate BS date')),
      isTrue,
    );
  });
}

List<PatroDate> _loadCalendar(int year) {
  final file = File('assets/data/calendar/$year.json');
  final json = jsonDecode(file.readAsStringSync()) as List<dynamic>;
  return json
      .map((item) => PatroDate.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<HolidayItem> _loadHolidays(int year) {
  final file = File('assets/data/holidays/${year}_holidays.json');
  final json = jsonDecode(file.readAsStringSync()) as List<dynamic>;
  return json
      .map((item) => HolidayItem.fromJson(item as Map<String, dynamic>))
      .toList();
}

String _ymd(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return normalized.toIso8601String().substring(0, 10);
}
