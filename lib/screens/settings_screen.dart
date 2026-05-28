import 'package:flutter/material.dart';

import '../controllers/app_settings_controller.dart';
import '../l10n/app_strings.dart';
import '../services/patro_repository.dart';
import '../widgets/app_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.repository});

  final PatroRepository repository;

  @override
  Widget build(BuildContext context) {
    final controller = AppSettingsScope.controllerOf(context);
    final strings = AppSettingsScope.stringsOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final currentStrings = AppStrings(controller.language);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: DropdownButtonFormField<AppLanguage>(
                  initialValue: controller.language,
                  decoration: InputDecoration(
                    labelText: 'Language / भाषा',
                    border: const OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AppLanguage.english,
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: AppLanguage.nepali,
                      child: Text('नेपाली'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setLanguage(value);
                  },
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                child: DropdownButtonFormField<ThemeMode>(
                  initialValue: controller.themeMode,
                  decoration: InputDecoration(
                    labelText: currentStrings.theme,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(currentStrings.lightMode),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(currentStrings.darkMode),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(currentStrings.systemDefault),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setThemeMode(value);
                  },
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calendar Data Status',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      repository.hasValidationErrors
                          ? currentStrings.calendarDataNeedsUpdate
                          : 'OK',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'App Version',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Text('1.0.0'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
