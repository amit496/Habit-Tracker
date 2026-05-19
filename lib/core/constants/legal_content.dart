import 'app_info.dart';

class LegalSection {
  final String title;
  final String body;

  const LegalSection({required this.title, required this.body});
}

class LegalContent {
  LegalContent._();

  static const privacyPolicy = [
    LegalSection(
      title: 'Overview',
      body:
          'HabitFlow (“the App”) is an offline habit tracker. Your habits, logs, '
          'notes, and settings are stored locally on your device. We do not operate '
          'user accounts, cloud sync, or analytics servers for this App.',
    ),
    LegalSection(
      title: 'Information we collect',
      body:
          'The App does not collect, transmit, or sell personal information to us.\n\n'
          'Data you enter (habit names, completion history, notes, reminders, and '
          'preferences) stays on your device unless you choose to export or share it '
          '(for example, JSON backup or CSV export via your device’s share sheet).',
    ),
    LegalSection(
      title: 'Device permissions',
      body:
          'The App may request the following permissions to provide features:\n\n'
          '• Notifications — to deliver habit reminders you configure.\n'
          '• Vibration — optional feedback with reminders.\n'
          '• Exact alarms (Android) — to schedule reminders at the times you set.\n'
          '• Storage / files — only when you pick a backup file to restore or choose '
          'a custom reminder sound.\n\n'
          'You can deny or revoke permissions in system Settings; related features may '
          'not work without them.',
    ),
    LegalSection(
      title: 'Third-party services',
      body:
          'The App does not include advertising or third-party analytics SDKs. '
          'Open-source libraries used in the App are listed under Licenses in Settings.',
    ),
    LegalSection(
      title: 'Data retention and deletion',
      body:
          'Your data remains on your device until you delete it in the App, restore '
          'from a backup, or uninstall the App. Uninstalling removes locally stored App data.',
    ),
    LegalSection(
      title: 'Children’s privacy',
      body:
          'The App is not directed at children under 13. We do not knowingly collect '
          'personal information from children.',
    ),
    LegalSection(
      title: 'Changes',
      body:
          'We may update this Privacy Policy from time to time. The in-app version and '
          'the published URL will reflect the current text. Continued use of the App '
          'after changes means you accept the updated policy.',
    ),
    LegalSection(
      title: 'Contact',
      body:
          'Questions about this Privacy Policy (in the app, open Settings → '
          'Legal → About):\n${AppInfo.contactEmail}',
    ),
  ];

  static const termsOfService = [
    LegalSection(
      title: 'Agreement',
      body:
          'By downloading or using HabitFlow, you agree to these Terms of Service. '
          'If you do not agree, do not use the App.',
    ),
    LegalSection(
      title: 'License',
      body:
          'We grant you a personal, non-exclusive, non-transferable license to use '
          'the App on your devices in accordance with these Terms and applicable '
          'store rules (Google Play, App Store, etc.).',
    ),
    LegalSection(
      title: 'Your content',
      body:
          'You are responsible for the habits, notes, and other content you create. '
          'You should back up important data using the App’s export features. We are '
          'not responsible for loss of data due to device failure, uninstall, or user error.',
    ),
    LegalSection(
      title: 'Disclaimer',
      body:
          'The App is provided “as is” without warranties of any kind. HabitFlow is a '
          'productivity tool only; it does not provide medical, psychological, or '
          'professional advice.',
    ),
    LegalSection(
      title: 'Limitation of liability',
      body:
          'To the fullest extent permitted by law, we are not liable for indirect, '
          'incidental, special, or consequential damages arising from your use of the App.',
    ),
    LegalSection(
      title: 'Updates',
      body:
          'We may update the App or these Terms. Material changes will be reflected '
          'in the in-app Terms and the published URL. Your continued use constitutes acceptance.',
    ),
    LegalSection(
      title: 'Termination',
      body:
          'You may stop using the App at any time by uninstalling it. We may discontinue '
          'or modify the App where permitted by law or store policies.',
    ),
    LegalSection(
      title: 'Contact',
      body:
          'For questions about these Terms (Settings → Legal → About):\n'
          '${AppInfo.contactEmail}',
    ),
  ];
}
