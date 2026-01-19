import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class MentorLearnerTimelineScreen extends StatefulWidget {
  final ApiClient api;
  final String learnerId;

  const MentorLearnerTimelineScreen({super.key, required this.api, required this.learnerId});

  @override
  State<MentorLearnerTimelineScreen> createState() => _MentorLearnerTimelineScreenState();
}

class _MentorLearnerTimelineScreenState extends State<MentorLearnerTimelineScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final json = await widget.api.get('/mentor/learners/${widget.learnerId}/timeline');
      final items = ((json as Map<String, dynamic>)['items'] as List).cast<Map<String, dynamic>>();
      setState(() => _items = items);
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load timeline', message: e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text(
          'Learning Trail',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: items.isEmpty
                  ? _EmptyTimeline()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) {
                        final t = items[i];
                        final status = t['status']?.toString() ?? '';
                        final score = t['score']?.toString();
                        final isLast = i == items.length - 1;

                        final statusColor = switch (status) {
                          'approved' => Colors.green,
                          'submitted' => scheme.primary,
                          'rejected' => Colors.redAccent,
                          _ => scheme.outline,
                        };

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Timeline Indicator
                              Column(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 4),
                                    ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: scheme.outlineVariant,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Content Card
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: scheme.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: scheme.outlineVariant),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                t['task_title']?.toString() ?? 'Untitled Milestone',
                                                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                                              ),
                                            ),
                                            if (score != null)
                                              Text(
                                                'Score: $score',
                                                style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline_rounded, size: 64, color: scheme.outline),
          const SizedBox(height: 16),
          Text(
            'No activities yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'The learning trail starts building once tasks are submitted and reviewed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
