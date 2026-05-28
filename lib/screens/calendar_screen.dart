import 'package:flutter/material.dart';

import '../models/patro_date.dart';
import '../services/patro_repository.dart';
import '../widgets/app_card.dart';
import 'date_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.repository});

  final PatroRepository repository;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _month;

  @override
  void initState() {
    super.initState();
    _month = widget.repository.today()?.bsMonth ?? 2;
  }

  @override
  Widget build(BuildContext context) {
    final month = widget.repository.monthByNumber(_month);
    final days = widget.repository.daysForMonth(_month);
    final offset = month.adStart.weekday % 7;
    final today = widget.repository.today();

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _month > 1 ? () => setState(() => _month--) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${month.nepaliName} ${nepaliNumber(widget.repository.year)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${month.name} ${month.adStart.year}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _month < 12 ? () => setState(() => _month++) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const _WeekHeader(),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: offset + days.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  if (index < offset) return const SizedBox.shrink();
                  final date = days[index - offset];
                  final isToday =
                      today?.bsMonth == date.bsMonth &&
                      today?.bsDay == date.bsDay;
                  return _DateCell(
                    date: date,
                    isToday: isToday,
                    onTap: () => _openDate(date),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _LegendDot(
              color: Theme.of(context).colorScheme.primary,
              label: 'पर्व / विदा',
            ),
            const SizedBox(width: 18),
            const _LegendDot(color: Color(0xFFD8C8C8), label: 'आज'),
          ],
        ),
        const SizedBox(height: 14),
        for (final date in days.where((item) => item.isHoliday))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: () => _openDate(date),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bsDate(date),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.holiday!.title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          date.holiday!.type,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _openDate(PatroDate date) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            DateDetailScreen(date: date, repository: widget.repository),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader();

  @override
  Widget build(BuildContext context) {
    const labels = ['आइत', 'सोम', 'मंगल', 'बुध', 'बिही', 'शुक्र', 'शनि'];
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.date,
    required this.isToday,
    required this.onTap,
  });

  final PatroDate date;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              nepaliNumber(date.bsDay),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isToday ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date.adDate.day.toString(),
              style: TextStyle(
                fontSize: 11,
                color: isToday ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: date.isHoliday
                    ? (isToday ? Colors.white : color)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}
