import 'package:flutter/material.dart';

import '../models/patro_date.dart';
import '../services/patro_repository.dart';
import '../theme/app_text_styles.dart';
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
      final haystack =
          '${holiday.title} ${holiday.titleNe ?? ''} ${holiday.type} ${holiday.appliesTo ?? ''}'
              .toLowerCase();
      return haystack.contains(_query.toLowerCase());
    }).toList();
    final categories = [
      _HolidayCategory(
        title: 'National Holidays',
        holidays: filtered.where((holiday) => holiday.type == 'national'),
      ),
      _HolidayCategory(
        title: 'Conditional / Community Holidays',
        holidays: filtered.where(
          (holiday) => {'community', 'gender', 'office'}.contains(holiday.type),
        ),
      ),
      _HolidayCategory(
        title: 'Provincial Holidays',
        holidays: filtered.where((holiday) => holiday.type == 'province'),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Text(
            'विदा तथा पर्व',
            style: AppTextStyles.title(context).copyWith(fontSize: 22),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'पर्व / विदा खोज्नुहोस्...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            hintStyle: AppTextStyles.subtitle(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final category in categories)
          if (category.holidays.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                category.title,
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
                  for (final holiday in category.sorted)
                    _HolidayTile(
                      holiday: holiday,
                      month: widget.repository.monthForYear(
                        holiday.bsYear,
                        holiday.month,
                      ),
                      onTap: () => _openHoliday(holiday),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        if (filtered.isEmpty)
          AppCard(
            child: Text(
              'मिल्दो पर्व वा विदा भेटिएन।',
              style: AppTextStyles.subtitle(context),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Source: Government of Nepal, Ministry of Home Affairs',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _openHoliday(HolidayItem holiday) {
    final date = widget.repository.fromBs(
      holiday.bsYear,
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

class _HolidayCategory {
  _HolidayCategory({
    required this.title,
    required Iterable<HolidayItem> holidays,
  }) : holidays = holidays.toList();

  final String title;
  final List<HolidayItem> holidays;

  List<HolidayItem> get sorted => [...holidays]
    ..sort((a, b) {
      final yearCompare = a.bsYear.compareTo(b.bsYear);
      if (yearCompare != 0) return yearCompare;
      final monthCompare = a.month.compareTo(b.month);
      if (monthCompare != 0) return monthCompare;
      return a.day.compareTo(b.day);
    });
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
                    style: AppTextStyles.body(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${nepaliNumber(2083)} ${month.nepaliName} ${nepaliNumber(holiday.day)}',
                    style: AppTextStyles.caption(
                      context,
                    ).copyWith(fontSize: 12),
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
                    style: AppTextStyles.body(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (holiday.titleNe != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      holiday.titleNe!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    holiday.appliesTo ?? holiday.type,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
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
