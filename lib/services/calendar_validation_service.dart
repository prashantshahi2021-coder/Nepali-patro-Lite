import '../models/patro_date.dart';
import 'nepali_date_service.dart';

class CalendarValidationResult {
  const CalendarValidationResult(this.errors);

  final List<String> errors;
  bool get isValid => errors.isEmpty;
}

class CalendarValidationService {
  const CalendarValidationService(this.dateService);

  final NepaliDateService dateService;

  CalendarValidationResult validate({
    required Map<int, List<PatroDate>> calendarsByYear,
    required Map<int, List<HolidayItem>> holidaysByYear,
  }) {
    final errors = <String>[];
    final allDates = calendarsByYear.values.expand((dates) => dates).toList();
    final adDates = <String>{};
    final bsDates = <String>{};

    for (final date in allDates) {
      final convertedBs = dateService.fromAd(date.adDate);
      if ((convertedBs.year, convertedBs.month, convertedBs.day) !=
          (date.bsYear, date.bsMonth, date.bsDay)) {
        errors.add(
          'AD date ${date.adKey} converts to ${convertedBs.key}, not ${date.bsKey}',
        );
      }

      final convertedAd = dateService.toAd(
        date.bsYear,
        date.bsMonth,
        date.bsDay,
      );
      if (dateKey(convertedAd) != date.adKey) {
        errors.add(
          'BS date ${date.bsKey} converts to ${dateKey(convertedAd)}, not ${date.adKey}',
        );
      }

      if (!adDates.add(date.adKey)) {
        errors.add('Duplicate AD date ${date.adKey}');
      }
      if (!bsDates.add(date.bsKey)) {
        errors.add('Duplicate BS date ${date.bsKey}');
      }
    }

    for (final entry in calendarsByYear.entries) {
      final year = entry.key;
      for (var month = 1; month <= 12; month++) {
        final actual = entry.value
            .where((date) => date.bsMonth == month)
            .length;
        final expected = dateService.daysInMonth(year, month);
        if (actual != expected) {
          errors.add(
            'Month day count mismatch for $year-$month: expected $expected, got $actual',
          );
        }
      }
    }

    for (final entry in holidaysByYear.entries) {
      final calendarKeys =
          calendarsByYear[entry.key]?.map((date) => date.bsKey).toSet() ??
          <String>{};
      for (final holiday in entry.value) {
        final key =
            '${holiday.bsYear}-${holiday.month.toString().padLeft(2, '0')}-${holiday.day.toString().padLeft(2, '0')}';
        final label = _holidayLabel(holiday);
        if (!calendarKeys.contains(key)) {
          errors.add('Holiday date missing in calendar JSON: $key ($label)');
        }

        try {
          final expectedAd = dateService.toAd(
            holiday.bsYear,
            holiday.month,
            holiday.day,
          );
          if (holiday.adDate != null &&
              dateKey(holiday.adDate!) != dateKey(expectedAd)) {
            errors.add(
              'Holiday AD mismatch for $key ($label): expected ${dateKey(expectedAd)}, got ${dateKey(holiday.adDate!)}',
            );
          }

          if (holiday.adDate != null) {
            final convertedBs = dateService.fromAd(holiday.adDate!);
            if ((convertedBs.year, convertedBs.month, convertedBs.day) !=
                (holiday.bsYear, holiday.month, holiday.day)) {
              errors.add(
                'Holiday BS mismatch for ${dateKey(holiday.adDate!)} ($label): expected $key, got ${convertedBs.key}',
              );
            }
          }
        } catch (error) {
          errors.add('Holiday conversion failed for $key ($label): $error');
        }
      }
    }

    if (errors.isNotEmpty) {
      // ignore: avoid_print
      print('Calendar validation failed:\n${errors.join('\n')}');
    }
    return CalendarValidationResult(errors);
  }

  String _holidayLabel(HolidayItem holiday) {
    final id = holiday.id == null ? 'no-id' : holiday.id!;
    return '$id "${holiday.title}"';
  }
}
