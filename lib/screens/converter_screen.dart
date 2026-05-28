import 'package:flutter/material.dart';

import '../models/patro_date.dart';
import '../services/patro_repository.dart';
import '../widgets/app_card.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key, required this.repository});

  final PatroRepository repository;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  bool _bsToAd = true;
  int _bsMonth = 2;
  int _bsDay = 15;
  final _adYear = TextEditingController(text: '2026');
  final _adMonth = TextEditingController(text: '5');
  final _adDay = TextEditingController(text: '29');
  PatroDate? _result;
  String? _message;

  @override
  void dispose() {
    _adYear.dispose();
    _adMonth.dispose();
    _adDay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Center(
          child: Text(
            'मिति रूपान्तरण',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 18),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('वि.सं. → ई.सं.')),
            ButtonSegment(value: false, label: Text('ई.सं. → वि.सं.')),
          ],
          selected: {_bsToAd},
          onSelectionChanged: (value) => setState(() {
            _bsToAd = value.first;
            _result = null;
            _message = null;
          }),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: _bsToAd
              ? _BsInput(
                  repository: widget.repository,
                  month: _bsMonth,
                  day: _bsDay,
                  onMonth: (value) => setState(() => _bsMonth = value),
                  onDay: (value) => setState(() => _bsDay = value),
                )
              : _AdInput(year: _adYear, month: _adMonth, day: _adDay),
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: _convert,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'रूपान्तरण गर्नुहोस्',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 18),
        if (_result != null)
          AppCard(
            color: const Color(0xFFFFF1F2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'परिणाम',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Text(
                  'वि.सं. मिति',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  bsDate(_result!),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'ई.सं. मिति',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  fullEnglishDate(_result!.adDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else if (_message != null)
          AppCard(
            child: Text(
              _message!,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        const SizedBox(height: 12),
        const Text(
          'नोट: यो रूपान्तरण नमुना डेटा २०८३ भित्र मात्र उपलब्ध छ।',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  void _convert() {
    setState(() {
      if (_bsToAd) {
        _result = widget.repository.fromBs(
          widget.repository.year,
          _bsMonth,
          _bsDay,
        );
      } else {
        final year = int.tryParse(_adYear.text.trim());
        final month = int.tryParse(_adMonth.text.trim());
        final day = int.tryParse(_adDay.text.trim());
        if (year == null || month == null || day == null) {
          _result = null;
          _message = 'कृपया सही ई.सं. मिति हाल्नुहोस्।';
          return;
        }
        _result = widget.repository.fromAd(DateTime(year, month, day));
      }
      _message = _result == null ? 'यो मिति नमुना डेटा भित्र भेटिएन।' : null;
    });
  }
}

class _BsInput extends StatelessWidget {
  const _BsInput({
    required this.repository,
    required this.month,
    required this.day,
    required this.onMonth,
    required this.onDay,
  });

  final PatroRepository repository;
  final int month;
  final int day;
  final ValueChanged<int> onMonth;
  final ValueChanged<int> onDay;

  @override
  Widget build(BuildContext context) {
    final currentMonth = repository.monthByNumber(month);
    final dayValue = day.clamp(1, currentMonth.days);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'वि.सं. मिति छान्नुहोस्',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _ReadOnlyField(nepaliNumber(repository.year)),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          initialValue: month,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: repository.months
              .map(
                (item) => DropdownMenuItem(
                  value: item.number,
                  child: Text(item.nepaliName),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            onMonth(value);
            final nextMax = repository.monthByNumber(value).days;
            if (day > nextMax) onDay(nextMax);
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          initialValue: dayValue,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: List.generate(currentMonth.days, (index) => index + 1)
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(nepaliNumber(item)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onDay(value);
          },
        ),
      ],
    );
  }
}

class _AdInput extends StatelessWidget {
  const _AdInput({required this.year, required this.month, required this.day});

  final TextEditingController year;
  final TextEditingController month;
  final TextEditingController day;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ई.सं. मिति हाल्नुहोस्',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: year,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Year',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: month,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Month',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: day,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Day',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
