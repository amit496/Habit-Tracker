import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/constants/app_info.dart';
import '../core/theme/app_theme.dart';
import '../widgets/habit_flow_logo.dart';
import 'legal_document_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        child: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snap) {
            final version = snap.data?.version ?? AppInfo.versionLabel;
            final build = snap.data?.buildNumber ?? '';

            return ListView(
              padding: AppTheme.screenPadding(context),
              children: [
                Center(
                  child: Column(
                    children: [
                      const HabitFlowLogoTile(size: 88),
                      const SizedBox(height: 16),
                      Text(
                        AppInfo.appName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        build.isEmpty
                            ? 'Version $version'
                            : 'Version $version ($build)',
                        style: TextStyle(color: AppTheme.mutedText(context)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppInfo.tagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _InfoCard(
                  title: 'What HabitFlow does',
                  body:
                      'Track daily habits, build streaks, view stats, set reminders, '
                      'and keep all data on your device — no account required.',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Offline & private',
                  body:
                      'No website, no cloud sync, and no ads. Your habits stay on '
                      'this phone unless you export a backup yourself.',
                ),
                const SizedBox(height: 24),
                Text(
                  'Legal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryFor(context),
                  ),
                ),
                const SizedBox(height: 8),
                _LinkTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read inside the app',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LegalDocumentScreen.privacyPolicy(),
                    ),
                  ),
                ),
                _LinkTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read inside the app',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LegalDocumentScreen.termsOfService(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Support',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryFor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.cardDecoration(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        AppInfo.contactEmail,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.primaryFor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Long-press the email to copy. Tap below to copy quickly.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.mutedText(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(text: AppInfo.contactEmail),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email copied')),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copy email'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _LinkTile(
                  icon: Icons.article_outlined,
                  title: 'Open-source licenses',
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppInfo.appName,
                    applicationVersion: version,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '© ${DateTime.now().year} ${AppInfo.developerName}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedText(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _InfoCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppTheme.mutedText(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkBorder
              : AppTheme.lightBorder,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryFor(context)),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
