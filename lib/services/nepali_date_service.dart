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
}
