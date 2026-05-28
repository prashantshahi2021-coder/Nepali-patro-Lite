import 'package:flutter/material.dart';

import 'controllers/app_settings_controller.dart';
import 'l10n/app_strings.dart';
import 'screens/calendar_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/holidays_screen.dart';
import 'screens/home_screen.dart';
import 'screens/more_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/patro_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<
    ({AppSettingsController settings, PatroRepository repository})
  >
  _load = _loadApp();

  Future<({AppSettingsController settings, PatroRepository repository})>
  _loadApp() async {
    final settings = AppSettingsController();
    await settings.load();
    final repository = await PatroRepository.load();
    return (settings: settings, repository: repository);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      ({AppSettingsController settings, PatroRepository repository})
    >(
      future: _load,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        return NepaliPatroLiteApp(
          settings: snapshot.data!.settings,
          repository: snapshot.data!.repository,
        );
      },
    );
  }
}

class NepaliPatroLiteApp extends StatelessWidget {
  const NepaliPatroLiteApp({
    super.key,
    required this.settings,
    required this.repository,
  });

  final AppSettingsController settings;
  final PatroRepository repository;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFD91F2A);
    return AppSettingsScope(
      controller: settings,
      child: AnimatedBuilder(
        animation: settings,
        builder: (context, _) {
          final lightScheme = ColorScheme.fromSeed(
            seedColor: red,
            primary: red,
            brightness: Brightness.light,
          );
          final darkScheme = ColorScheme.fromSeed(
            seedColor: red,
            primary: red,
            brightness: Brightness.dark,
          );
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Nepali Patro Lite',
            themeMode: settings.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightScheme,
              scaffoldBackgroundColor: lightScheme.surface,
              appBarTheme: AppBarTheme(
                backgroundColor: lightScheme.surface,
                elevation: 0,
                centerTitle: true,
                foregroundColor: lightScheme.primary,
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: lightScheme.surface,
                indicatorColor: lightScheme.primaryContainer,
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    color: selected
                        ? lightScheme.onPrimaryContainer
                        : lightScheme.onSurfaceVariant,
                  );
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    color: selected
                        ? lightScheme.onSurface
                        : lightScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  );
                }),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkScheme,
              scaffoldBackgroundColor: darkScheme.surface,
              appBarTheme: AppBarTheme(
                backgroundColor: darkScheme.surface,
                elevation: 0,
                centerTitle: true,
                foregroundColor: darkScheme.primary,
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: darkScheme.surface,
                indicatorColor: darkScheme.primaryContainer,
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    color: selected
                        ? darkScheme.onPrimaryContainer
                        : darkScheme.onSurfaceVariant,
                  );
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    color: selected
                        ? darkScheme.onSurface
                        : darkScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  );
                }),
              ),
            ),
            home: settings.onboardingCompleted
                ? AppShell(repository: repository)
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.repository});

  final PatroRepository repository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final strings = AppSettingsScope.stringsOf(context);
    final screens = [
      HomeScreen(
        repository: widget.repository,
        openTab: (index) => setState(() => _index = index),
      ),
      CalendarScreen(repository: widget.repository),
      ConverterScreen(repository: widget.repository),
      HolidaysScreen(repository: widget.repository),
      MoreScreen(repository: widget.repository),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_index]),
      bottomNavigationBar: NavigationBar(
        height: 64,
        selectedIndex: _index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: strings.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: strings.calendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.swap_horiz),
            label: strings.converter,
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag),
            label: strings.holidays,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu),
            label: strings.more,
          ),
        ],
      ),
    );
  }
}
