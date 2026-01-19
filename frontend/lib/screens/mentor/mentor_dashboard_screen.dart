import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_controller.dart';
import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class MentorDashboardScreen extends StatefulWidget {
  final AuthController auth;
  final ApiClient api;
  final Future<void> Function() openNotifications;

  const MentorDashboardScreen({
    super.key,
    required this.auth,
    required this.api,
    required this.openNotifications,
  });

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen> {
  bool _loading = true;
  Map<String, dynamic>? _data;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final json = await widget.api.get('/mentor/dashboard');
      final unread = await widget.api.get('/notifications/unread-count', auth: true);
      setState(() {
        _data = (json as Map<String, dynamic>);
        _unreadNotifications = (unread as Map<String, dynamic>)['count'] as int? ?? 0;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load dashboard', message: e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _notificationsButton() {
    final count = _unreadNotifications;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () async {
            try {
              await widget.openNotifications();
              if (!mounted) return;
              await _load();
            } catch (_) {
              if (!mounted) return;
              showAppSnack(context, 'Unable to open notifications');
            }
          },
          icon: const Icon(Icons.notifications_none),
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final name = widget.auth.user?.fullName ?? widget.auth.user?.email.split('@')[0] ?? 'Mentor';

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHigh,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        title: Text(
          'Mentor Hub',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: [
          _notificationsButton(),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: scheme.primary.withValues(alpha: 0.1),
              child: IconButton(
                onPressed: widget.auth.logout,
                icon: Icon(Icons.logout_rounded, size: 18, color: scheme.primary),
                tooltip: 'Logout',
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  // Personalized Greeting Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [scheme.secondary, scheme.secondary.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.secondary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_outlined, color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'MENTOR MODE',
                              style: textTheme.labelMedium?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Ready to guide, $name?',
                          style: textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You have ${_data?['pendingReviews'] ?? 0} submissions waiting for your feedback.',
                          style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Quick Access Status
                  Row(
                    children: [
                      Expanded(
                        child: _MentorActionCard(
                          label: 'Review Queue',
                          value: '${_data?['pendingReviews'] ?? 0}',
                          icon: Icons.reviews_outlined,
                          color: Colors.orange,
                          onTap: () async {
                            await context.push('/mentor/submissions');
                            if (!mounted) return;
                            await _load();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MentorActionCard(
                          label: 'My Programs',
                          value: '${(_data?['assignedLearners'] ?? []).length}',
                          icon: Icons.topic_outlined,
                          color: scheme.primary,
                          onTap: () => context.push('/mentor/programs'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Assigned Learners',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  if (((_data?['assignedLearners'] ?? []) as List).isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.group_off_outlined, size: 48, color: scheme.outline),
                          const SizedBox(height: 16),
                          const Text('No learners assigned to you yet'),
                        ],
                      ),
                    )
                  else
                    ...(((_data?['assignedLearners'] ?? []) as List)
                        .cast<Map<String, dynamic>>()
                        .map(
                          (u) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: scheme.primary.withValues(alpha: 0.1),
                                  child: Text(
                                    (u['full_name']?.toString() ?? 'U')[0].toUpperCase(),
                                    style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(u['full_name']?.toString() ?? 'Unnamed Learner'),
                                subtitle: Text(u['email']?.toString() ?? ''),
                                trailing: const Icon(Icons.timeline_rounded, size: 20),
                                onTap: () {
                                  final id = u['id'] as String?;
                                  if (id != null) context.push('/mentor/learners/$id/timeline');
                                },
                              ),
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

class _MentorActionCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MentorActionCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
