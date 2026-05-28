import 'package:flutter/material.dart';

import '../controllers/app_settings_controller.dart';

class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    super.key,
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSettingsController controllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>()!
        .notifier!;
  }

  static AppStrings stringsOf(BuildContext context) {
    return AppStrings(controllerOf(context).language);
  }
}

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;
  bool get _ne => language == AppLanguage.nepali;

  String get home => _ne ? 'गृह' : 'Home';
  String get calendar => _ne ? 'क्यालेन्डर' : 'Calendar';
  String get converter => _ne ? 'रूपान्तरण' : 'Converter';
  String get holidays => _ne ? 'विदा' : 'Holidays';
  String get more => _ne ? 'थप' : 'More';
  String get settings => _ne ? 'सेटिङ्स' : 'Settings';
  String get today => _ne ? 'आज' : 'Today';
  String get dateConverter => _ne ? 'मिति रूपान्तरण' : 'Date Converter';
  String get lightMode => _ne ? 'लाइट मोड' : 'Light Mode';
  String get darkMode => _ne ? 'डार्क मोड' : 'Dark Mode';
  String get systemDefault => _ne ? 'सिस्टम डिफल्ट' : 'System Default';
  String get languageText => _ne ? 'भाषा' : 'Language';
  String get theme => _ne ? 'थिम' : 'Theme';
  String get noEventAdded => _ne
      ? 'यस मितिमा कुनै कार्यक्रम थपिएको छैन'
      : 'No event added for this date';
  String get calendarDataNeedsUpdate => _ne
      ? 'क्यालेन्डर डेटा अपडेट गर्न आवश्यक छ'
      : 'Calendar data needs update';
  String get adToBs => _ne ? 'ई.सं. बाट वि.सं.' : 'AD to BS';
  String get bsToAd => _ne ? 'वि.सं. बाट ई.सं.' : 'BS to AD';
  String get clear => _ne ? 'खाली गर्नुहोस्' : 'Clear';
  String get convert => _ne ? 'रूपान्तरण गर्नुहोस्' : 'Convert';
  String get chooseLanguage => _ne
      ? 'Choose your language / आफ्नो भाषा छान्नुहोस्'
      : 'Choose your language / आफ्नो भाषा छान्नुहोस्';
}
