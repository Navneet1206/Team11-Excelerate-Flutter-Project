import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class MentorProgramOverviewScreen extends StatefulWidget {
  final ApiClient api;
  final String programId;

  const MentorProgramOverviewScreen({super.key, required this.api, required this.programId});

  @override
  State<MentorProgramOverviewScreen> createState() => _MentorProgramOverviewScreenState();
}

class _MentorProgramOverviewScreenState extends State<MentorProgramOverviewScreen> {
  bool _loading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final json = await widget.api.get('/mentor/programs/${widget.programId}/overview');
      setState(() => _data = (json as Map<String, dynamic>));
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load program', message: e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final learners = ((_data?['learners'] ?? []) as List).cast<Map<String, dynamic>>();
    final tasks = ((_data?['tasks'] ?? []) as List).cast<Map<String, dynamic>>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text(
          'Cohort Overview',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filledTonal(
              tooltip: 'Cohort Reviews',
              onPressed: () => context.push('/mentor/programs/${widget.programId}/reviews'),
              icon: const Icon(Icons.reviews_rounded, size: 20),
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
                  _SectionHeader(title: 'Active Learners', icon: Icons.groups_rounded, count: learners.length),
                  const SizedBox(height: 16),
                  if (learners.isEmpty)
                    _EmptyHint(text: 'No learners assigned to this program cohort yet.', icon: Icons.person_add_disabled_rounded)
                  else
                    ...learners.map((u) {
                      final name = u['full_name']?.toString() ?? 'Learner';
                      final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: scheme.primary.withValues(alpha: 0.1),
                            child: Text(initial, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                          subtitle: Text(u['email']?.toString() ?? '', style: textTheme.bodySmall),
                          trailing: Icon(Icons.chevron_right_rounded, color: scheme.outline, size: 20),
                        ),
                      );
                    }),
                  
                  const SizedBox(height: 32),
                  _SectionHeader(title: 'Milestone Progress', icon: Icons.auto_graph_rounded, count: tasks.length),
                  const SizedBox(height: 16),
                  if (tasks.isEmpty)
                    _EmptyHint(text: 'No curriculum tasks defined for this program.', icon: Icons.assignment_late_rounded)
                  else
                    ...tasks.map((t) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t['title']?.toString() ?? 'Untitled Task', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _StatusBox(label: 'Pending', count: t['pending'], color: Colors.orange),
                                  const SizedBox(width: 8),
                                  _StatusBox(label: 'Approved', count: t['approved'], color: Colors.green),
                                  const SizedBox(width: 8),
                                  _StatusBox(label: 'Changes', count: t['rejected'], color: Colors.redAccent),
                                ],
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  const _SectionHeader({required this.title, required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary, letterSpacing: 0.5),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('$count', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }
}

class _StatusBox extends StatelessWidget {
  final String label;
  final dynamic count;
  final Color color;
  const _StatusBox({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.1))),
        child: Column(
          children: [
            Text('${count ?? 0}', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
            Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontWeight: FontWeight.bold, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  final IconData icon;
  const _EmptyHint({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: scheme.outlineVariant)),
      child: Column(
        children: [
          Icon(icon, color: scheme.outline, size: 32),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
        ],
      ),
    );
  }
}
