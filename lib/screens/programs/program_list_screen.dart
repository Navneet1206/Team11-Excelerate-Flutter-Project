import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../ui/app_buttons.dart';
import '../../ui/app_card.dart';

/// Screen Owner: Member 3
///
/// Minimal placeholder screen.
/// Implement a paginated program list here.
///
/// Rules:
/// - Pagination is mandatory.
/// - Do not cache sensitive/dynamic data.
/// - Keep API calls minimal.
class ProgramListScreen extends StatelessWidget {
  const ProgramListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Program Listing Screen (placeholder)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'TODO: Fetch and show programs here (paginated).\n'
                  'Use card style: radius 16, white surface, soft shadow.\n'
                  'Arrow icon should use Accent/Sky Blue.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const Spacer(),
            AppPrimaryButton(
              label: 'Open Program Details (placeholder)',
              onPressed: () => Navigator.of(context).pushNamed(Routes.programDetails),
            ),
          ],
        ),
      ),
    );
  }
}
