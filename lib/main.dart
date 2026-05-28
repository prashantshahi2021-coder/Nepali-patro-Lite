import 'package:flutter/material.dart';

import 'screens/calendar_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/holidays_screen.dart';
import 'screens/home_screen.dart';
import 'screens/more_screen.dart';
import 'services/patro_repository.dart';

void main() {
  runApp(const NepaliPatroLiteApp());
}

class NepaliPatroLiteApp extends StatelessWidget {
  const NepaliPatroLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFD91F2A);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nepali Patro Lite',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: red,
          primary: red,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFFEFEFE),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          foregroundColor: red,
        ),
        fontFamily: 'Roboto',
      ),
      home: const RepositoryLoader(),
    );
  }
}

class RepositoryLoader extends StatefulWidget {
  const RepositoryLoader({super.key});

  @override
  State<RepositoryLoader> createState() => _RepositoryLoaderState();
}

class _RepositoryLoaderState extends State<RepositoryLoader> {
  late final Future<PatroRepository> _repository = PatroRepository.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatroRepository>(
      future: _repository,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AppShell(repository: snapshot.data!);
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Calendar data error: ${snapshot.error}')),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Converter',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Holidays',
          ),
          NavigationDestination(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }
}
