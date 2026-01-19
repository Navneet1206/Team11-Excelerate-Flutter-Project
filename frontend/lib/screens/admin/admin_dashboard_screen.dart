import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_controller.dart';
import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AuthController auth;
  final ApiClient api;
  final Future<void> Function() openNotifications;

  const AdminDashboardScreen({
    super.key,
    required this.auth,
    required this.api,
    required this.openNotifications,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _trends = const [];
  List<Map<String, dynamic>> _ranking = const [];
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final trends = await widget.api.get('/admin/analytics/completion-trends');
      final ranking = await widget.api.get('/admin/analytics/learner-ranking');
      final unread = await widget.api.get('/notifications/unread-count', auth: true);

      setState(() {
        _trends = ((trends as Map<String, dynamic>)['items'] as List).cast<Map<String, dynamic>>();
        _ranking = ((ranking as Map<String, dynamic>)['items'] as List).cast<Map<String, dynamic>>();
        _unreadNotifications = (unread as Map<String, dynamic>)['count'] as int? ?? 0;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load analytics', message: e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _notificationsButton() {
    final count = _unreadNotifications;
    final scheme = Theme.of(context).colorScheme;
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
          icon: Icon(count > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_rounded, size: 22),
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: IgnorePointer(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.surface, width: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.auth.user?.fullName ?? widget.auth.user?.email ?? 'Administrator';
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text(
          'Admin Console',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: [
          _notificationsButton(),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(onPressed: widget.auth.logout, icon: const Icon(Icons.logout_rounded)),
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
                  // Greeting
                  Text(
                    'Hey, $name',
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  Text(
                    'System Status: All systems operational',
                    style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),

                  // Quick Actions
                  Text(
                    'MANAGEMENT HUB',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _QuickActionCard(
                            width: width,
                            title: 'Users',
                            icon: Icons.people_alt_rounded,
                            onTap: () => context.push('/admin/users'),
                            subtitle: 'Manage learners & mentors',
                          ),
                          _QuickActionCard(
                            width: width,
                            title: 'Programs',
                            icon: Icons.collections_bookmark_rounded,
                            onTap: () => context.push('/admin/programs'),
                            subtitle: 'Manage curriculum tasks',
                          ),
                          _QuickActionCard(
                            width: width,
                            title: 'Audit Logs',
                            icon: Icons.security_rounded,
                            onTap: () => context.push('/admin/audit-logs'),
                            subtitle: 'View system activity',
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                  // Analytics Section
                  Text(
                    'COMPLETION TRENDS',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 16),
                  if (_trends.isEmpty)
                    _EmptyAnalyticsHint(message: 'No trend data yet.')
                  else
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _trends.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (ctx, i) {
                          final t = _trends[i];
                          return Container(
                            width: 160,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: scheme.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${t['week']}', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800)),
                                const Spacer(),
                                _MiniStat(label: 'Done', count: t['approved'], color: Colors.green),
                                const SizedBox(height: 4),
                                _MiniStat(label: 'Pending', count: t['submitted'], color: Colors.orange),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 40),
                  // Leaderboard
                  Text(
                    'TOP PERFORMERS',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 16),
                  if (_ranking.isEmpty)
                    _EmptyAnalyticsHint(message: 'No rankings available yet.')
                  else
                    ..._ranking.take(5).map((r) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: scheme.primary.withValues(alpha: 0.1),
                              child: Text('${_ranking.indexOf(r) + 1}', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(r['full_name']?.toString() ?? 'Learner', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                            subtitle: Text('Score: ${r['approved_count']}', style: textTheme.bodySmall),
                          ),
                        )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final double width;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({required this.width, required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: scheme.primary, size: 20),
                ),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final dynamic count;
  final Color color;
  const _MiniStat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text('${count ?? 0}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _EmptyAnalyticsHint extends StatelessWidget {
  final String message;
  const _EmptyAnalyticsHint({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: scheme.outlineVariant)),
      child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
    );
  }
}
