import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../theme/app_colors.dart';
import '../../ui/app_buttons.dart';
import '../../ui/app_card.dart';

/// Screen Owner: Member 1
///
/// This file is intentionally kept minimal so the assigned team member can
/// implement the full UI later.
///
/// Design rules:
/// - Background: AppColors.background (#F7F9FC)
/// - Input cards: AppColors.surface (#FFFFFF) with radius 16
/// - Primary CTA: AppColors.accent (#4F9DFF), height 48
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SkillTrack Pro',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Login Screen (placeholder)',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // TODO: Add logo here (centered).
                          // TODO: Add email + password inputs.
                          // TODO: Add validation (lightweight, UI-only).
                          // NOTE: Any auth/permission checks must be on backend.
                          const Text('Inputs will be implemented by Member 1.'),
                          const SizedBox(height: 16),
                          AppPrimaryButton(
                            label: 'Continue',
                            onPressed: () {
                              // TODO later: call auth API.
                              Navigator.of(context)
                                  .pushReplacementNamed(Routes.home);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Prototype scaffold only (no auth yet)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
