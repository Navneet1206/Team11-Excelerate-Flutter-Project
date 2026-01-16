import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../ui/app_buttons.dart';
import '../../ui/app_card.dart';
import '../../ui/app_popup.dart';

/// Screen Owner: Member 2
///
/// Minimal placeholder screen.
/// Implement the real Home UI here using the design tokens.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              // TODO later:
              // - Fetch unread badge count (backend)
              // - Show notification list (custom popup/screen)
              AppPopup.showInfo(
                context,
                title: 'Notifications',
                message: 'To be implemented by Member 2 (or shared module).',
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Home Screen (placeholder)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.insights_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dashboard widgets will be implemented by Member 2.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppPrimaryButton(
              label: 'Browse Programs',
              onPressed: () => Navigator.of(context).pushNamed(Routes.programList),
            ),
            const SizedBox(height: 12),
            AppOutlineButton(
              label: 'Logout (placeholder)',
              onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.login),
            ),
          ],
        ),
      ),
    );
  }
}
