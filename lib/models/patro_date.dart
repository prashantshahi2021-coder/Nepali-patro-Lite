class BsDate {
  const BsDate({required this.year, required this.month, required this.day});

  final int year;
  final int month;
  final int day;

  String get key => '$year-${_two(month)}-${_two(day)}';
}

class PatroMonth {
  const PatroMonth({
    required this.number,
    required this.name,
    required this.nepaliName,
    required this.days,
    required this.adStart,
  });

  final int number;
  final String name;
  final String nepaliName;
  final int days;
  final DateTime adStart;
}

class HolidayItem {
  const HolidayItem({
    this.id,
    required this.bsYear,
    required this.month,
    required this.day,
    required this.title,
    this.titleNe,
    required this.type,
    required this.source,
    this.adDate,
    this.appliesTo,
    this.sourceUrl,
    this.verified = false,
  });

  final String? id;
  final int bsYear;
  final int month;
  final int day;
  final String title;
  final String? titleNe;
  final String type;
  final String source;
  final DateTime? adDate;
  final String? appliesTo;
  final String? sourceUrl;
  final bool verified;

  factory HolidayItem.fromJson(Map<String, dynamic> json) {
    final bsDate = json['bs_date'] as String?;
    final bsParts = bsDate?.split('-').map(int.parse).toList();
    return HolidayItem(
      id: json['id'] as String?,
      bsYear: bsParts?[0] ?? json['bs_year'] as int,
      month: bsParts?[1] ?? json['bs_month'] as int,
      day: bsParts?[2] ?? json['bs_day'] as int,
      title:
          json['title_en'] as String? ??
          json['holiday_name'] as String? ??
          json['title'] as String,
      titleNe: json['title_ne'] as String?,
      type: json['type'] as String? ?? 'Holiday',
      source: json['source_name'] as String? ?? json['source'] as String,
      adDate: json['ad_date'] == null
          ? null
          : DateTime.parse(json['ad_date'] as String),
      appliesTo: json['applies_to'] as String?,
      sourceUrl: json['source_url'] as String?,
      verified: json['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bs_year': bsYear,
      'bs_month': month,
      'bs_day': day,
      'bs_date':
          '$bsYear-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      'ad_date': adDate == null ? null : dateKey(adDate!),
      'title_en': title,
      'title_ne': titleNe,
      'holiday_name': title,
      'type': type,
      'applies_to': appliesTo,
      'source_name': source,
      'source_url': sourceUrl,
      'verified': verified,
    };
  }
}

class PatroDate {
  const PatroDate({
    required this.bsYear,
    required this.bsMonth,
    required this.bsDay,
    required this.adDate,
    required this.weekday,
    required this.isToday,
    required this.isHoliday,
    required this.holidayName,
    required this.eventName,
    required this.notes,
    required this.source,
  });

  final int bsYear;
  final int bsMonth;
  final int bsDay;
  final DateTime adDate;
  final String weekday;
  final bool isToday;
  final bool isHoliday;
  final String? holidayName;
  final String? eventName;
  final String? notes;
  final String source;

  String get monthName => englishMonthName(bsMonth);
  String get nepaliMonthName => nepaliMonthNameFor(bsMonth);
  String get bsKey => '$bsYear-${_two(bsMonth)}-${_two(bsDay)}';
  String get adKey => dateKey(adDate);

  HolidayItem? get holiday {
    if (!isHoliday || holidayName == null || holidayName!.isEmpty) return null;
    return HolidayItem(
      bsYear: bsYear,
      month: bsMonth,
      day: bsDay,
      title: holidayName!,
      type: 'Holiday',
      source: source,
    );
  }

  factory PatroDate.fromJson(Map<String, dynamic> json) {
    return PatroDate(
      bsYear: json['bs_year'] as int,
      bsMonth: json['bs_month'] as int,
      bsDay: json['bs_day'] as int,
      adDate: DateTime.parse(json['ad_date'] as String),
      weekday: json['weekday'] as String,
      isToday: json['is_today'] as bool? ?? false,
      isHoliday: json['is_holiday'] as bool? ?? false,
      holidayName: _nullableString(json['holiday_name']),
      eventName: _nullableString(json['event_name']),
      notes: _nullableString(json['notes']),
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bs_year': bsYear,
      'bs_month': bsMonth,
      'bs_day': bsDay,
      'ad_date': dateKey(adDate),
      'weekday': weekday,
      'is_today': isToday,
      'is_holiday': isHoliday,
      'holiday_name': holidayName,
      'event_name': eventName,
      'notes': notes,
      'source': source,
    };
  }
}

class CalendarDataVersion {
  const CalendarDataVersion({
    required this.version,
    required this.supportedYears,
    required this.lastVerified,
    required this.source,
    this.calendarUrl,
    this.holidaysUrl,
    this.lastUpdated,
  });

  final String version;
  final List<int> supportedYears;
  final String lastVerified;
  final String source;
  final String? calendarUrl;
  final String? holidaysUrl;
  final String? lastUpdated;

  String get calendarDataVersion => version;
  List<int> get supportedBsYears => supportedYears;

  factory CalendarDataVersion.fromJson(Map<String, dynamic> json) {
    return CalendarDataVersion(
      version: (json['version'] ?? json['calendar_data_version']) as String,
      supportedYears:
          ((json['supported_years'] ?? json['supported_bs_years'])
                  as List<dynamic>)
              .cast<int>(),
      lastVerified: json['last_verified'] as String,
      source:
          json['source'] as String? ??
          'Government of Nepal holiday list + verified BS/AD converter',
      calendarUrl: json['calendar_url'] as String?,
      holidaysUrl: json['holidays_url'] as String?,
      lastUpdated: json['last_updated'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'supported_years': supportedYears,
      'calendar_url': calendarUrl,
      'holidays_url': holidaysUrl,
      'last_verified': lastVerified,
      'last_updated': lastUpdated,
      'source': source,
    };
  }
}

String dateKey(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return '${normalized.year}-${_two(normalized.month)}-${_two(normalized.day)}';
}

String englishMonthName(int month) {
  const names = [
    'Baisakh',
    'Jestha',
    'Asar',
    'Shrawan',
    'Bhadra',
    'Ashwin',
    'Kartik',
    'Mangsir',
    'Poush',
    'Magh',
    'Falgun',
    'Chaitra',
  ];
  return names[month - 1];
}

String nepaliMonthNameFor(int month) {
  const names = [
    'Baisakh',
    'Jestha',
    'Asar',
    'Shrawan',
    'Bhadra',
    'Ashwin',
    'Kartik',
    'Mangsir',
    'Poush',
    'Magh',
    'Falgun',
    'Chaitra',
  ];
  return names[month - 1];
}

String _two(int value) => value.toString().padLeft(2, '0');

String? _nullableString(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}
