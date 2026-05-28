import 'package:nepali_utils/nepali_utils.dart';

import '../models/patro_date.dart';

class NepaliDateService {
  BsDate fromAd(DateTime adDate) {
    final normalized = DateTime.utc(
      adDate.year,
      adDate.month,
      adDate.day,
    ).subtract(const Duration(days: 1));
    final bs = normalized.toNepaliDateTime();
    return BsDate(year: bs.year, month: bs.month, day: bs.day);
  }

  DateTime toAd(int bsYear, int bsMonth, int bsDay) {
    final ad = NepaliDateTime(bsYear, bsMonth, bsDay).toDateTime();
    return DateTime(ad.year, ad.month, ad.day);
  }

  int daysInMonth(int bsYear, int bsMonth) {
    return NepaliDateTime(bsYear, bsMonth).totalDays;
  }

  DateConversionResult convertAdToBs({
    required int year,
    required int month,
    required int day,
  }) {
    if (month < 1 || month > 12 || day < 1) {
      return const DateConversionResult.failure('Invalid English date.');
    }
    final adDate = DateTime(year, month, day);
    if (adDate.year != year || adDate.month != month || adDate.day != day) {
      return const DateConversionResult.failure('Invalid English date.');
    }
    try {
      final bsDate = fromAd(adDate);
      return DateConversionResult.success(bsDate: bsDate, adDate: adDate);
    } catch (_) {
      return const DateConversionResult.failure(
        'This date is outside supported range.',
      );
    }
  }

  DateConversionResult convertBsToAd({
    required int year,
    required int month,
    required int day,
  }) {
    if (month < 1 || month > 12 || day < 1) {
      return const DateConversionResult.failure(
        'This date is outside supported range.',
      );
    }
    try {
      final maxDay = daysInMonth(year, month);
      if (day > maxDay) {
        return const DateConversionResult.failure(
          'This date is outside supported range.',
        );
      }
      final adDate = toAd(year, month, day);
      return DateConversionResult.success(
        bsDate: BsDate(year: year, month: month, day: day),
        adDate: adDate,
      );
    } catch (_) {
      return const DateConversionResult.failure(
        'This date is outside supported range.',
      );
    }
  }
}

class DateConversionResult {
  const DateConversionResult._({this.bsDate, this.adDate, this.error});

  const DateConversionResult.success({
    required BsDate bsDate,
    required DateTime adDate,
  }) : this._(bsDate: bsDate, adDate: adDate);

  const DateConversionResult.failure(String error) : this._(error: error);

  final BsDate? bsDate;
  final DateTime? adDate;
  final String? error;

  bool get isSuccess => bsDate != null && adDate != null;
}
