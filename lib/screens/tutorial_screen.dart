import 'package:flutter/material.dart';

import '../core/constants/tutorial_topics.dart';
import '../core/theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../widgets/tutorial_topic_card.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppTheme.screenPadding(context).copyWith(top: 8),
          children: [
            const ScreenHeader(
              subtitle: 'Learn how to use HabitFlow',
              title: 'App tutorial',
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a topic to expand step-by-step instructions.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.mutedText(context),
              ),
            ),
            const SizedBox(height: 20),
            ...TutorialTopics.all.map(
              (topic) => TutorialTopicCard(topic: topic),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration(context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppTheme.primaryFor(context),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: Long-press any habit on Today to add a daily note. '
                      'Use Stats to review streaks and your yearly activity heatmap.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: AppTheme.mutedText(context),
                      ),
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
