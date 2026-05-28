import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/patro_date.dart';
import '../services/nepali_date_service.dart';
import '../services/patro_repository.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key, required this.repository});

  final PatroRepository repository;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _dateService = NepaliDateService();
  bool _adToBs = true;
  DateTime? _adDate = DateTime.now();
  int _bsYear = 2083;
  int _bsMonth = 1;
  int _bsDay = 1;
  DateConversionResult? _result;
  String? _message;

  @override
  void initState() {
    super.initState();
    final bs = _dateService.fromAd(DateTime.now());
    _bsYear = bs.year;
    _bsMonth = bs.month;
    _bsDay = bs.day;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppSettingsScope.stringsOf(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Text(
            strings.dateConverter,
            style: AppTextStyles.title(context).copyWith(fontSize: 22),
          ),
        ),
        const SizedBox(height: 18),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: true, label: Text(strings.adToBs)),
            ButtonSegment(value: false, label: Text(strings.bsToAd)),
          ],
          selected: {_adToBs},
          onSelectionChanged: (value) => setState(() {
            _adToBs = value.first;
            _result = null;
            _message = null;
          }),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: _adToBs
              ? _AdPicker(date: _adDate, onPick: _pickAdDate)
              : _BsPicker(
                  year: _bsYear,
                  month: _bsMonth,
                  day: _bsDay,
                  service: _dateService,
                  onChanged: _setBsDate,
                ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _convert,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  strings.convert,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: _clear,
              style: OutlinedButton.styleFrom(minimumSize: const Size(96, 52)),
              child: Text(strings.clear),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_result?.isSuccess == true)
          _ResultCard(result: _result!)
        else if (_message != null)
          AppCard(
            child: Text(_message!, style: AppTextStyles.subtitle(context)),
          ),
      ],
    );
  }

  Future<void> _pickAdDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _adDate ?? DateTime.now(),
      firstDate: DateTime(1913, 4, 13),
      lastDate: DateTime(2193, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _adDate = picked;
        _result = null;
        _message = null;
      });
    }
  }

  void _setBsDate(int year, int month, int day) {
    setState(() {
      _bsYear = year;
      _bsMonth = month;
      _bsDay = day;
      _result = null;
      _message = null;
    });
  }

  void _convert() {
    setState(() {
      if (_adToBs) {
        if (_adDate == null) {
          _message = 'Empty fields are not allowed.';
          _result = null;
          return;
        }
        _result = _dateService.convertAdToBs(
          year: _adDate!.year,
          month: _adDate!.month,
          day: _adDate!.day,
        );
      } else {
        _result = _dateService.convertBsToAd(
          year: _bsYear,
          month: _bsMonth,
          day: _bsDay,
        );
      }
      _message = _result!.isSuccess ? null : _result!.error;
    });
  }

  void _clear() {
    setState(() {
      _result = null;
      _message = null;
      _adDate = null;
    });
  }
}

class _AdPicker extends StatelessWidget {
  const _AdPicker({required this.date, required this.onPick});

  final DateTime? date;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('English date', style: AppTextStyles.body(context)),
      subtitle: Text(
        date == null ? 'Select a date' : englishDate(date!),
        style: AppTextStyles.subtitle(context),
      ),
      trailing: const Icon(Icons.calendar_month),
      onTap: onPick,
    );
  }
}

class _BsPicker extends StatelessWidget {
  const _BsPicker({
    required this.year,
    required this.month,
    required this.day,
    required this.service,
    required this.onChanged,
  });

  final int year;
  final int month;
  final int day;
  final NepaliDateService service;
  final void Function(int year, int month, int day) onChanged;

  @override
  Widget build(BuildContext context) {
    final maxDay = service.daysInMonth(year, month);
    final safeDay = day.clamp(1, maxDay);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nepali date',
          style: AppTextStyles.body(
            context,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: year,
          decoration: const InputDecoration(
            labelText: 'Year',
            border: OutlineInputBorder(),
          ),
          items: List.generate(282, (index) => 1969 + index)
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.toString()),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value, month, safeDay);
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          initialValue: month,
          decoration: const InputDecoration(
            labelText: 'Month',
            border: OutlineInputBorder(),
          ),
          items: List.generate(12, (index) => index + 1)
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text('${nepaliMonthNameFor(value)} ($value)'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            final nextMax = service.daysInMonth(year, value);
            onChanged(year, value, safeDay.clamp(1, nextMax));
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          initialValue: safeDay,
          decoration: const InputDecoration(
            labelText: 'Day',
            border: OutlineInputBorder(),
          ),
          items: List.generate(maxDay, (index) => index + 1)
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.toString()),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(year, month, value);
          },
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final DateConversionResult result;

  @override
  Widget build(BuildContext context) {
    final bs = result.bsDate!;
    final ad = result.adDate!;
    return AppCard(
      color: Theme.of(context).colorScheme.primaryContainer.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.24 : 0.45,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Result',
            style: AppTextStyles.title(context).copyWith(fontSize: 18),
          ),
          const SizedBox(height: 14),
          _Row(
            label: 'Nepali date',
            value: '${nepaliMonthNameFor(bs.month)} ${bs.day}, ${bs.year}',
          ),
          _Row(label: 'English date', value: englishDate(ad)),
          _Row(label: 'Day name', value: englishWeekday(ad)),
          _Row(label: 'Month name', value: nepaliMonthNameFor(bs.month)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.subtitle(context))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body(
                context,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
