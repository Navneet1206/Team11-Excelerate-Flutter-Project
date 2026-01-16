import 'package:flutter/material.dart';

import '../../ui/app_buttons.dart';
import '../../ui/app_card.dart';
import '../../ui/app_popup.dart';

/// Screen Owner: Member 4
///
/// Minimal placeholder screen.
/// Implement program details UI here.
class ProgramDetailScreen extends StatelessWidget {
  const ProgramDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Program Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.10),
                      ),
                      child: Icon(
                        Icons.school_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Program Details (placeholder)',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'TODO: show program title/subtitle here',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'About',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'TODO: show program description here.\n'
              'Top section can include program image/title as per README spec.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            AppPrimaryButton(
              label: 'Enroll',
              onPressed: () {
                // TODO later: call enroll API and show success/error popup.
                AppPopup.showInfo(
                  context,
                  title: 'Enroll',
                  message: 'Enroll flow will be implemented by Member 4.',
                );
              },
            ),
            const SizedBox(height: 12),
            AppOutlineButton(
              label: 'Back',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
