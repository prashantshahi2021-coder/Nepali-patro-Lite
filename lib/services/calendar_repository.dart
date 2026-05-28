import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/patro_date.dart';
import 'calendar_validation_service.dart';
import 'nepali_date_service.dart';

class CalendarRepository {
  CalendarRepository._({
    required this.version,
    required this.calendarsByYear,
    required this.holidaysByYear,
    required this.dateService,
    required this.loadedFromCache,
    required this.validationErrors,
  }) {
    if (validationErrors.isNotEmpty) {
      debugPrint('Calendar validation failed: $validationErrors');
    }
  }

  static const cachedVersionKey = 'calendar_version_json';
  static const cachedCalendarPrefix = 'calendar_json_';
  static const cachedHolidaysPrefix = 'holidays_json_';

  final CalendarDataVersion version;
  final Map<int, List<PatroDate>> calendarsByYear;
  final Map<int, List<HolidayItem>> holidaysByYear;
  final NepaliDateService dateService;
  final bool loadedFromCache;
  final List<String> validationErrors;

  bool get hasValidationErrors => validationErrors.isNotEmpty;
  int get year => today()?.bsYear ?? version.supportedYears.last;
  List<HolidayItem> get holidays =>
      holidaysByYear.values.expand((items) => items).toList();
  List<PatroMonth> get months => monthsForYear(year);

  static Future<CalendarRepository> load({
    AssetBundle? assetBundle,
    SharedPreferences? preferences,
  }) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final cached = await _tryLoadCached(prefs);
    if (cached != null) return cached;
    return loadBundled(assetBundle: assetBundle);
  }

  static Future<CalendarRepository> loadBundled({
    AssetBundle? assetBundle,
  }) async {
    final bundle = assetBundle ?? rootBundle;
    final versionText = await bundle.loadString(
      'assets/data/calendar_version.json',
    );
    final version = CalendarDataVersion.fromJson(
      jsonDecode(versionText) as Map<String, dynamic>,
    );
    final calendarsByYear = <int, List<PatroDate>>{};
    final holidaysByYear = <int, List<HolidayItem>>{};

    for (final year in version.supportedYears) {
      final calendarText = await bundle.loadString(
        'assets/data/calendar/$year.json',
      );
      final holidayText = await bundle.loadString(
        'assets/data/holidays/${year}_holidays.json',
      );
      calendarsByYear[year] = parseCalendar(calendarText);
      holidaysByYear[year] = parseHolidays(
        holidayText,
        calendarDates: calendarsByYear[year],
        year: year,
      );
    }
    final dateService = NepaliDateService();
    final validation = CalendarValidationService(dateService).validate(
      calendarsByYear: calendarsByYear,
      holidaysByYear: holidaysByYear,
    );

    return CalendarRepository._(
      version: version,
      calendarsByYear: calendarsByYear,
      holidaysByYear: holidaysByYear,
      dateService: dateService,
      loadedFromCache: false,
      validationErrors: validation.errors,
    );
  }

  static Future<CalendarRepository?> _tryLoadCached(
    SharedPreferences prefs,
  ) async {
    try {
      final versionText = prefs.getString(cachedVersionKey);
      if (versionText == null) return null;
      final version = CalendarDataVersion.fromJson(
        jsonDecode(versionText) as Map<String, dynamic>,
      );
      final calendarsByYear = <int, List<PatroDate>>{};
      final holidaysByYear = <int, List<HolidayItem>>{};
      for (final year in version.supportedYears) {
        final calendarText = prefs.getString('$cachedCalendarPrefix$year');
        final holidaysText = prefs.getString('$cachedHolidaysPrefix$year');
        if (calendarText == null || holidaysText == null) return null;
        calendarsByYear[year] = parseCalendar(calendarText);
        holidaysByYear[year] = parseHolidays(
          holidaysText,
          calendarDates: calendarsByYear[year],
          year: year,
        );
      }
      final dateService = NepaliDateService();
      final result = CalendarValidationService(dateService).validate(
        calendarsByYear: calendarsByYear,
        holidaysByYear: holidaysByYear,
      );
      if (!result.isValid) {
        debugPrint('Cached calendar validation failed: ${result.errors}');
        return null;
      }
      return CalendarRepository._(
        version: version,
        calendarsByYear: calendarsByYear,
        holidaysByYear: holidaysByYear,
        dateService: dateService,
        loadedFromCache: true,
        validationErrors: result.errors,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCache({
    required SharedPreferences preferences,
    required CalendarDataVersion version,
    required Map<int, String> calendarJsonByYear,
    required Map<int, String> holidaysJsonByYear,
  }) async {
    await preferences.setString(cachedVersionKey, jsonEncode(version.toJson()));
    for (final year in version.supportedYears) {
      final calendarJson = calendarJsonByYear[year];
      final holidaysJson = holidaysJsonByYear[year];
      if (calendarJson != null) {
        await preferences.setString('$cachedCalendarPrefix$year', calendarJson);
      }
      if (holidaysJson != null) {
        await preferences.setString('$cachedHolidaysPrefix$year', holidaysJson);
      }
    }
  }

  static List<PatroDate> parseCalendar(String text) {
    final dates = <PatroDate>[];
    final items = jsonDecode(text) as List<dynamic>;
    for (var index = 0; index < items.length; index++) {
      try {
        dates.add(PatroDate.fromJson(items[index] as Map<String, dynamic>));
      } catch (error) {
        debugPrint('Calendar record ignored at index $index: $error');
      }
    }
    return dates;
  }

  static List<HolidayItem> parseHolidays(
    String text, {
    List<PatroDate>? calendarDates,
    int? year,
  }) {
    final holidays = <HolidayItem>[];
    final calendarKeys = calendarDates?.map((date) => date.bsKey).toSet();
    final items = jsonDecode(text) as List<dynamic>;
    for (var index = 0; index < items.length; index++) {
      try {
        final holiday = HolidayItem.fromJson(
          items[index] as Map<String, dynamic>,
        );
        final key =
            '${holiday.bsYear}-${holiday.month.toString().padLeft(2, '0')}-${holiday.day.toString().padLeft(2, '0')}';
        final wrongYear = year != null && holiday.bsYear != year;
        final missingDate = calendarKeys != null && !calendarKeys.contains(key);
        if (wrongYear || missingDate) {
          debugPrint(
            'Holiday record ignored at index $index: $key is not in calendar data',
          );
          continue;
        }
        holidays.add(holiday);
      } catch (error) {
        debugPrint('Holiday record ignored at index $index: $error');
      }
    }
    return holidays;
  }

  PatroMonth monthByNumber(int month) => monthForYear(year, month);

  PatroMonth monthForYear(int bsYear, int month) {
    final days = daysForMonth(month, bsYear: bsYear);
    if (days.isEmpty) {
      return PatroMonth(
        number: month,
        name: englishMonthName(month),
        nepaliName: nepaliMonthNameFor(month),
        days: 0,
        adStart: DateTime(1970),
      );
    }
    return PatroMonth(
      number: month,
      name: englishMonthName(month),
      nepaliName: nepaliMonthNameFor(month),
      days: days.length,
      adStart: days.first.adDate,
    );
  }

  List<PatroMonth> monthsForYear(int bsYear) {
    return List.generate(12, (index) => monthForYear(bsYear, index + 1));
  }

  List<PatroDate> daysForMonth(int monthNumber, {int? bsYear}) {
    final selectedYear = bsYear ?? year;
    return calendarsByYear[selectedYear]
            ?.where((date) => date.bsMonth == monthNumber)
            .map(_withHoliday)
            .toList() ??
        const [];
  }

  HolidayItem? holidayFor(int month, int day, {int? bsYear}) {
    final selectedYear = bsYear ?? year;
    for (final holiday
        in holidaysByYear[selectedYear] ?? const <HolidayItem>[]) {
      if (holiday.month == month && holiday.day == day) return holiday;
    }
    return null;
  }

  PatroDate? today() => fromAd(DateTime.now());

  PatroDate? fromAd(DateTime adDate) {
    final key = dateKey(adDate);
    for (final dates in calendarsByYear.values) {
      for (final date in dates) {
        if (date.adKey == key) return _withHoliday(date);
      }
    }
    return null;
  }

  PatroDate? fromBs(int bsYear, int bsMonth, int bsDay) {
    final key =
        '$bsYear-${bsMonth.toString().padLeft(2, '0')}-${bsDay.toString().padLeft(2, '0')}';
    for (final date in calendarsByYear[bsYear] ?? const <PatroDate>[]) {
      if (date.bsKey == key) return _withHoliday(date);
    }
    return null;
  }

  PatroDate _withHoliday(PatroDate date) {
    final holidays = (holidaysByYear[date.bsYear] ?? const <HolidayItem>[])
        .where(
          (holiday) =>
              holiday.month == date.bsMonth && holiday.day == date.bsDay,
        )
        .toList();
    if (holidays.isEmpty) return date;

    final names = holidays.map((holiday) => holiday.title).join(' / ');
    return PatroDate(
      bsYear: date.bsYear,
      bsMonth: date.bsMonth,
      bsDay: date.bsDay,
      adDate: date.adDate,
      weekday: date.weekday,
      isToday: date.isToday,
      isHoliday: true,
      holidayName: names,
      eventName: date.eventName ?? names,
      notes: date.notes,
      source: holidays.first.source,
    );
  }
}

String nepaliNumber(Object value) {
  const digits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
  return value.toString().split('').map((char) {
    final number = int.tryParse(char);
    return number == null ? char : digits[number];
  }).join();
}

String englishDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String fullEnglishDate(DateTime date) {
  return '${englishDate(date)} (${englishWeekday(date)})';
}

String englishWeekday(DateTime date) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return days[date.weekday - 1];
}

String nepaliWeekday(DateTime date) {
  const days = [
    'सोमबार',
    'मंगलबार',
    'बुधबार',
    'बिहीबार',
    'शुक्रबार',
    'शनिबार',
    'आइतबार',
  ];
  return days[date.weekday - 1];
}

String bsDate(PatroDate date) {
  return '${date.nepaliMonthName} ${nepaliNumber(date.bsDay)}, ${nepaliNumber(date.bsYear)}';
}
