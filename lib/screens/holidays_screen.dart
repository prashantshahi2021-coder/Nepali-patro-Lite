import 'package:flutter/material.dart';

import '../models/patro_date.dart';
import '../services/patro_repository.dart';
import '../widgets/app_card.dart';
import 'date_detail_screen.dart';

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key, required this.repository});

  final PatroRepository repository;

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.repository.holidays.where((holiday) {
      final haystack = '${holiday.title} ${holiday.type}'.toLowerCase();
      return haystack.contains(_query.toLowerCase());
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Center(
          child: Text(
            'विदा तथा पर्व',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'पर्व / विदा खोज्नुहोस्...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFFF6F6F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final month in widget.repository.months)
          if (filtered.any((holiday) => holiday.month == month.number)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                month.nepaliName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final holiday in filtered.where(
                    (item) => item.month == month.number,
                  ))
                    _HolidayTile(
                      holiday: holiday,
                      month: month,
                      onTap: () => _openHoliday(holiday),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        if (filtered.isEmpty)
          const AppCard(
            child: Text(
              'मिल्दो पर्व वा विदा भेटिएन।',
              style: TextStyle(color: Colors.black54),
            ),
          ),
      ],
    );
  }

  void _openHoliday(HolidayItem holiday) {
    final date = widget.repository.fromBs(
      widget.repository.year,
      holiday.month,
      holiday.day,
    );
    if (date == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            DateDetailScreen(date: date, repository: widget.repository),
      ),
    );
  }
}

class _HolidayTile extends StatelessWidget {
  const _HolidayTile({
    required this.holiday,
    required this.month,
    required this.onTap,
  });

  final HolidayItem holiday;
  final PatroMonth month;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.flag, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${nepaliNumber(holiday.day)} ${month.nepaliName}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${nepaliNumber(2083)} ${month.nepaliName} ${nepaliNumber(holiday.day)}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holiday.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    holiday.type,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
