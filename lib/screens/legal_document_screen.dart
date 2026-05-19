import 'package:flutter/material.dart';

import '../core/constants/legal_content.dart';
import '../core/theme/app_theme.dart';

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final List<LegalSection> sections;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.sections,
  });

  factory LegalDocumentScreen.privacyPolicy() {
    return const LegalDocumentScreen(
      title: 'Privacy Policy',
      sections: LegalContent.privacyPolicy,
    );
  }

  factory LegalDocumentScreen.termsOfService() {
    return const LegalDocumentScreen(
      title: 'Terms of Service',
      sections: LegalContent.termsOfService,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: AppTheme.screenPadding(context),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryFor(context).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.smartphone_rounded,
                    size: 20,
                    color: AppTheme.primaryFor(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This policy is included in the app. No website is required to use HabitFlow.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: May 2026',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.mutedText(context),
              ),
            ),
            const SizedBox(height: 20),
            ...sections.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.body,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
