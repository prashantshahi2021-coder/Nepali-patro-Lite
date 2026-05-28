import 'package:flutter/material.dart';

import '../models/patro_date.dart';
import '../services/patro_repository.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';

class DateDetailScreen extends StatelessWidget {
  const DateDetailScreen({
    super.key,
    required this.date,
    required this.repository,
  });

  final PatroDate date;
  final PatroRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Date Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RedHeaderCard(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  bsDate(date),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nepaliWeekday(date.adDate),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(fullEnglishDate(date.adDate)),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                _InfoRow('Day', date.weekday),
                _InfoRow('BS date', bsDate(date)),
                _InfoRow('AD date', englishDate(date.adDate)),
                _InfoRow(
                  'Event/festival',
                  date.eventName ??
                      date.holidayName ??
                      'Data not available for this date',
                  accent: date.isHoliday,
                ),
                _InfoRow(
                  'Holiday status',
                  date.isHoliday
                      ? 'Holiday'
                      : 'Data not available for this date',
                  accent: date.isHoliday,
                ),
                _InfoRow('Source', date.source),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panchang',
                  style: AppTextStyles.title(context).copyWith(fontSize: 17),
                ),
                const SizedBox(height: 12),
                Text(
                  'Panchang data coming soon',
                  style: AppTextStyles.body(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.accent = false});

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body(context))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: accent
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: accent ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
