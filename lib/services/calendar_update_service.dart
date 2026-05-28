import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/patro_date.dart';
import 'calendar_repository.dart';
import 'calendar_validation_service.dart';
import 'nepali_date_service.dart';

class CalendarUpdateService {
  CalendarUpdateService({
    http.Client? client,
    Connectivity? connectivity,
    SharedPreferences? preferences,
    this.remoteVersionUrl = remoteVersionUrlPlaceholder,
  }) : _client = client ?? http.Client(),
       _connectivity = connectivity ?? Connectivity(),
       _preferences = preferences;

  static const remoteVersionUrlPlaceholder =
      'https://example.com/nepali-patro-lite/calendar_version.json';

  final http.Client _client;
  final Connectivity _connectivity;
  final SharedPreferences? _preferences;
  final String remoteVersionUrl;

  Future<CalendarUpdateResult> checkForUpdate({
    CalendarDataVersion? currentVersion,
    Future<bool> Function()? hasInternet,
  }) async {
    final online = hasInternet == null
        ? await _hasInternet()
        : await hasInternet();
    if (!online) {
      return const CalendarUpdateResult.skipped('No internet connection');
    }

    try {
      final versionResponse = await _client.get(Uri.parse(remoteVersionUrl));
      if (versionResponse.statusCode != 200) {
        return const CalendarUpdateResult.failed('Remote version unavailable');
      }

      final remoteVersion = CalendarDataVersion.fromJson(
        jsonDecode(versionResponse.body) as Map<String, dynamic>,
      );
      if (currentVersion != null &&
          !_isNewer(remoteVersion.version, currentVersion.version)) {
        return const CalendarUpdateResult.skipped(
          'Calendar data is already up to date',
        );
      }

      final calendarJsonByYear = <int, String>{};
      final holidaysJsonByYear = <int, String>{};
      final calendarsByYear = <int, List<PatroDate>>{};
      final holidaysByYear = <int, List<HolidayItem>>{};

      for (final year in remoteVersion.supportedYears) {
        final calendarUrl = _urlForYear(
          remoteVersion.calendarUrl,
          year,
          'calendar',
        );
        final holidaysUrl = _urlForYear(
          remoteVersion.holidaysUrl,
          year,
          'holidays',
        );
        final calendarResponse = await _client.get(Uri.parse(calendarUrl));
        final holidaysResponse = await _client.get(Uri.parse(holidaysUrl));
        if (calendarResponse.statusCode != 200 ||
            holidaysResponse.statusCode != 200) {
          return CalendarUpdateResult.failed(
            'Remote data unavailable for $year',
          );
        }
        calendarJsonByYear[year] = calendarResponse.body;
        holidaysJsonByYear[year] = holidaysResponse.body;
        calendarsByYear[year] = CalendarRepository.parseCalendar(
          calendarResponse.body,
        );
        holidaysByYear[year] = CalendarRepository.parseHolidays(
          holidaysResponse.body,
        );
      }

      final validation = CalendarValidationService(NepaliDateService())
          .validate(
            calendarsByYear: calendarsByYear,
            holidaysByYear: holidaysByYear,
          );
      if (!validation.isValid) {
        return CalendarUpdateResult.failed(
          'Downloaded calendar data failed validation',
        );
      }

      final prefs = _preferences ?? await SharedPreferences.getInstance();
      final savedVersion = CalendarDataVersion(
        version: remoteVersion.version,
        supportedYears: remoteVersion.supportedYears,
        calendarUrl: remoteVersion.calendarUrl,
        holidaysUrl: remoteVersion.holidaysUrl,
        lastVerified: remoteVersion.lastVerified,
        lastUpdated: DateTime.now().toIso8601String().substring(0, 10),
        source: remoteVersion.source,
      );
      await CalendarRepository.saveCache(
        preferences: prefs,
        version: savedVersion,
        calendarJsonByYear: calendarJsonByYear,
        holidaysJsonByYear: holidaysJsonByYear,
      );

      return CalendarUpdateResult.updated(savedVersion.version);
    } catch (error) {
      return CalendarUpdateResult.failed('Update failed: $error');
    }
  }

  Future<bool> _hasInternet() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  bool _isNewer(String remote, String local) {
    final remoteParts = remote
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    final localParts = local
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    final length = remoteParts.length > localParts.length
        ? remoteParts.length
        : localParts.length;
    for (var i = 0; i < length; i++) {
      final remoteValue = i < remoteParts.length ? remoteParts[i] : 0;
      final localValue = i < localParts.length ? localParts[i] : 0;
      if (remoteValue > localValue) return true;
      if (remoteValue < localValue) return false;
    }
    return false;
  }

  String _urlForYear(String? template, int year, String type) {
    if (template == null || template.isEmpty) {
      return 'https://example.com/${type}_$year.json';
    }
    return template.replaceAll('2083', year.toString());
  }
}

enum CalendarUpdateStatus { updated, skipped, failed }

class CalendarUpdateResult {
  const CalendarUpdateResult._(this.status, this.message);
  const CalendarUpdateResult.updated(String version)
    : this._(CalendarUpdateStatus.updated, 'Updated to $version');
  const CalendarUpdateResult.skipped(String message)
    : this._(CalendarUpdateStatus.skipped, message);
  const CalendarUpdateResult.failed(String message)
    : this._(CalendarUpdateStatus.failed, message);

  final CalendarUpdateStatus status;
  final String message;
}
