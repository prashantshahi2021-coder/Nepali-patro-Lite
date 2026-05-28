import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, nepali }

class AppSettingsController extends ChangeNotifier {
  AppSettingsController({SharedPreferences? preferences})
    : _preferences = preferences;

  static const _languageKey = 'app_language';
  static const _themeKey = 'theme_mode';
  static const _onboardingKey = 'onboarding_completed';

  SharedPreferences? _preferences;
  AppLanguage _language = AppLanguage.english;
  ThemeMode _themeMode = ThemeMode.system;
  bool _onboardingCompleted = false;

  AppLanguage get language => _language;
  ThemeMode get themeMode => _themeMode;
  bool get onboardingCompleted => _onboardingCompleted;

  Future<void> load() async {
    _preferences ??= await SharedPreferences.getInstance();
    _language = switch (_preferences!.getString(_languageKey)) {
      'nepali' => AppLanguage.nepali,
      _ => AppLanguage.english,
    };
    _themeMode = switch (_preferences!.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _onboardingCompleted = _preferences!.getBool(_onboardingKey) ?? false;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
    notifyListeners();
    await _preferences!.setString(
      _languageKey,
      language == AppLanguage.nepali ? 'nepali' : 'english',
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    await _preferences!.setString(_themeKey, switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }

  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;
    notifyListeners();
    await _preferences!.setBool(_onboardingKey, true);
  }
}
