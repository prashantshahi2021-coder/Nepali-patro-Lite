import 'package:flutter/material.dart';

import '../controllers/app_settings_controller.dart';
import '../l10n/app_strings.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppSettingsScope.controllerOf(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.calendar_month,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Choose your language / आफ्नो भाषा छान्नुहोस्',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () async {
                  await controller.setLanguage(AppLanguage.english);
                  await controller.completeOnboarding();
                },
                child: const Text('English'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await controller.setLanguage(AppLanguage.nepali);
                  await controller.completeOnboarding();
                },
                child: const Text('नेपाली'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
