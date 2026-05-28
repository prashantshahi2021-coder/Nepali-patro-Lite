import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/calendar_update_service.dart';
import '../services/patro_repository.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.repository});

  final PatroRepository repository;

  @override
  Widget build(BuildContext context) {
    final version = repository.version;
    final strings = AppSettingsScope.stringsOf(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Text(
            strings.more,
            style: AppTextStyles.title(context).copyWith(fontSize: 22),
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
                child: Icon(
                  Icons.calendar_month,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nepali Patro Lite',
                      style: AppTextStyles.title(
                        context,
                      ).copyWith(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Simple Nepali Calendar',
                      style: AppTextStyles.subtitle(context),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Version 1.0.0',
                      style: AppTextStyles.subtitle(context),
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
              Text(
                'Calendar Data',
                style: AppTextStyles.title(context).copyWith(fontSize: 18),
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
                  strings.calendarDataNeedsUpdate,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  repository.validationErrors.take(3).join('\n'),
                  style: AppTextStyles.caption(context).copyWith(fontSize: 12),
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
          child: Column(
            children: [
              _MoreTile(
                icon: Icons.info_outline,
                title: strings.settings,
                subtitle: '${strings.languageText} / ${strings.theme}',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(repository: repository),
                  ),
                ),
              ),
              _Divider(),
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

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: AppTextStyles.body(
          context,
        ).copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.subtitle(context)),
      trailing: const Icon(Icons.chevron_right),
      onTap:
          onTap ??
          () {
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
