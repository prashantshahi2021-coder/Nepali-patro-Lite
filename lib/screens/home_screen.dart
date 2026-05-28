import 'package:flutter/material.dart';

import '../services/patro_repository.dart';
import '../widgets/app_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.openTab,
  });

  final PatroRepository repository;
  final ValueChanged<int> openTab;

  @override
  Widget build(BuildContext context) {
    final today = repository.today();
    if (today == null) {
      final bs = repository.dateService.fromAd(DateTime.now());
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        children: [
          const Text(
            'Nepali Patro Lite',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          const Text(
            'Simple Nepali Calendar',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          RedHeaderCard(
            children: [
              const Text(
                'Calendar data needs update',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${bs.year}-${bs.month.toString().padLeft(2, '0')}-${bs.day.toString().padLeft(2, '0')} BS',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(fullEnglishDate(DateTime.now())),
            ],
          ),
          const SizedBox(height: 18),
          const AppCard(child: Text('Data not available for this date')),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nepali Patro Lite',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Simple Nepali Calendar',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
        const SizedBox(height: 20),
        RedHeaderCard(
          children: [
            Text(
              nepaliWeekday(today.adDate),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                bsDate(today),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fullEnglishDate(today.adDate),
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          color: const Color(0xFFFFF1F2),
          child: Row(
            children: [
              Icon(
                Icons.event_note,
                color: Theme.of(context).colorScheme.primary,
                size: 34,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      today.eventName ??
                          today.holidayName ??
                          'Data not available for this date',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      today.isHoliday
                          ? 'Holiday'
                          : 'No verified holiday data available',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.25,
          children: [
            _QuickButton(
              icon: Icons.calendar_month,
              title: 'Calendar',
              subtitle: 'Monthly view',
              onTap: () => openTab(1),
            ),
            _QuickButton(
              icon: Icons.swap_horiz,
              title: 'Date Converter',
              subtitle: 'AD and BS',
              onTap: () => openTab(2),
            ),
            _QuickButton(
              icon: Icons.flag,
              title: 'Holidays',
              subtitle: 'Verified only',
              onTap: () => openTab(3),
            ),
            _QuickButton(
              icon: Icons.wb_sunny_outlined,
              title: 'Panchang',
              subtitle: 'Coming soon',
              onTap: () => openTab(1),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
