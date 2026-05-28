import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_patro_lite/controllers/app_settings_controller.dart';
import 'package:nepali_patro_lite/services/nepali_date_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('AD to BS converter works without local calendar JSON lookup', () {
    final service = NepaliDateService();

    final result = service.convertAdToBs(year: 2026, month: 5, day: 28);

    expect(result.isSuccess, isTrue);
    expect(result.adDate, DateTime(2026, 5, 28));
    final roundTrip = service.convertBsToAd(
      year: result.bsDate!.year,
      month: result.bsDate!.month,
      day: result.bsDate!.day,
    );
    expect(roundTrip.adDate, DateTime(2026, 5, 28));
  });

  test('BS to AD converter validates month day overflow', () {
    final service = NepaliDateService();

    final result = service.convertBsToAd(year: 2083, month: 2, day: 99);

    expect(result.isSuccess, isFalse);
    expect(result.error, 'This date is outside supported range.');
  });

  test('AD converter rejects invalid English date', () {
    final service = NepaliDateService();

    final result = service.convertAdToBs(year: 2026, month: 2, day: 31);

    expect(result.isSuccess, isFalse);
    expect(result.error, 'Invalid English date.');
  });

  test(
    'settings controller persists language, theme, and onboarding',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = AppSettingsController(preferences: prefs);
      await controller.load();

      await controller.setLanguage(AppLanguage.nepali);
      await controller.setThemeMode(ThemeMode.dark);
      await controller.completeOnboarding();

      final reloaded = AppSettingsController(preferences: prefs);
      await reloaded.load();

      expect(reloaded.language, AppLanguage.nepali);
      expect(reloaded.themeMode, ThemeMode.dark);
      expect(reloaded.onboardingCompleted, isTrue);
    },
  );
}
