import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_controller.dart';
import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class LearnerDashboardScreen extends StatefulWidget {
  final AuthController auth;
  final ApiClient api;
  final Future<void> Function() openNotifications;

  const LearnerDashboardScreen({
    super.key,
    required this.auth,
    required this.api,
    required this.openNotifications,
  });

  @override
  State<LearnerDashboardScreen> createState() => _LearnerDashboardScreenState();
}

class _LearnerDashboardScreenState extends State<LearnerDashboardScreen> {
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
      final json = await widget.api.get('/learner/dashboard');
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
    final name = widget.auth.user?.fullName ?? widget.auth.user?.email.split('@')[0] ?? 'Learner';

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHigh,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        title: Text(
          'Dashboard',
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
                        colors: [scheme.primary, scheme.primary.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.2),
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
                            const Icon(Icons.wb_sunny_outlined, color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'GROWTH MODE',
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
                          'Welcome back, $name!',
                          style: textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You have completed ${_data?['completionPercentage'] ?? 0}% of your current goals.',
                          style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Stats Section
                  Row(
                    children: [
                      Text(
                        'Your Progress',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.push('/learner/performance'),
                        child: const Text('View Report'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatCard(
                          label: 'Pending',
                          value: '${_data?['pendingTasks'] ?? 0}',
                          icon: Icons.timer_outlined,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Approved',
                          value: '${_data?['approvedTasks'] ?? 0}',
                          icon: Icons.check_circle_outline_rounded,
                          color: scheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Overall',
                          value: '${_data?['completionPercentage'] ?? 0}%',
                          icon: Icons.auto_awesome_outlined,
                          color: scheme.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                   // Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Programs',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        onPressed: () => context.push('/learner/programs'),
                        icon: Icon(Icons.grid_view_rounded, color: scheme.primary, size: 20),
                        tooltip: 'Browse All',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (((_data?['activePrograms'] ?? []) as List).isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.library_books_rounded, size: 48, color: scheme.outline),
                          const SizedBox(height: 16),
                          const Text('No active programs yet'),
                          TextButton(
                            onPressed: () => context.push('/learner/programs'),
                            child: const Text('Enroll in a Program'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...(((_data?['activePrograms'] ?? []) as List)
                        .cast<Map<String, dynamic>>()
                        .map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: scheme.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.school_rounded, color: scheme.primary, size: 24),
                                ),
                                title: Text(p['title']?.toString() ?? ''),
                                subtitle: Text(
                                  p['description']?.toString() ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                onTap: () {
                                  final id = p['id'] as String?;
                                  if (id != null) {
                                    context.push('/learner/programs/$id');
                                  }
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: scheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
