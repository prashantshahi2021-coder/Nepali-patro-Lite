import 'package:flutter/material.dart';

import '../services/calendar_update_service.dart';
import '../services/patro_repository.dart';
import '../widgets/app_card.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.repository});

  final PatroRepository repository;

  @override
  Widget build(BuildContext context) {
    final version = repository.version;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Center(
          child: Text(
            'More',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nepali Patro Lite',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Simple Nepali Calendar',
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Calendar Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _DataRow('Calendar Data Version', version.calendarDataVersion),
              _DataRow('Last Updated', version.lastUpdated ?? 'Bundled data'),
              _DataRow('Last Verified Date', version.lastVerified),
              _DataRow('Supported Years', version.supportedBsYears.join(', ')),
              _DataRow('Data Source', version.source),
              if (repository.hasValidationErrors) ...[
                const SizedBox(height: 12),
                Text(
                  'Calendar data needs update',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  repository.validationErrors.take(3).join('\n'),
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final result = await CalendarUpdateService().checkForUpdate(
                      currentVersion: version,
                    );
                    messenger.showSnackBar(
                      SnackBar(content: Text(result.message)),
                    );
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Check for Calendar Update'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: EdgeInsets.zero,
          child: const Column(
            children: [
              _MoreTile(
                icon: Icons.info_outline,
                title: 'About App',
                subtitle: 'About this app',
              ),
              _Divider(),
              _MoreTile(
                icon: Icons.lock_outline,
                title: 'Privacy Policy',
                subtitle: 'Privacy Policy',
              ),
              _Divider(),
              _MoreTile(
                icon: Icons.star_outline,
                title: 'Rate App',
                subtitle: 'Rate App',
              ),
              _Divider(),
              _MoreTile(
                icon: Icons.share_outlined,
                title: 'Share App',
                subtitle: 'Share App',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$subtitle placeholder')));
      },
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 56);
  }
}
