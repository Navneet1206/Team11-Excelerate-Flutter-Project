import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class MentorProgramsScreen extends StatefulWidget {
  final ApiClient api;

  const MentorProgramsScreen({super.key, required this.api});

  @override
  State<MentorProgramsScreen> createState() => _MentorProgramsScreenState();
}

class _MentorProgramsScreenState extends State<MentorProgramsScreen> {
  static const _pageSize = 20;

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({required bool reset}) async {
    if (_loadingMore) return;
    if (!reset && !_hasMore) return;

    setState(() {
      if (reset) {
        _loading = true;
      } else {
        _loadingMore = true;
      }
    });

    try {
      final nextOffset = reset ? 0 : _offset;
      final json = await widget.api.get('/mentor/programs', query: {
        'limit': '$_pageSize',
        'offset': '$nextOffset',
      });
      final items = ((json as Map<String, dynamic>)['items'] as List).cast<Map<String, dynamic>>();

      setState(() {
        if (reset) _items.clear();
        _items.addAll(items);
        _offset = nextOffset + items.length;
        _hasMore = items.length == _pageSize;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load programs', message: e.message);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text(
          'Mentorship Portfolio',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: _items.isEmpty
                  ? _EmptyPrograms()
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _items.length + (_hasMore ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        if (i == _items.length) {
                          if (!_loadingMore) _load(reset: false);
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final p = _items[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              final id = p['id'] as String?;
                              if (id != null) context.push('/mentor/programs/$id');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: scheme.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.school_rounded, color: scheme.primary, size: 20),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    p['title']?.toString() ?? 'Untitled Program',
                                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      _SmallStat(
                                        icon: Icons.groups_rounded,
                                        value: '${p['learner_count'] ?? 0}',
                                        label: 'Learners',
                                      ),
                                      const SizedBox(width: 24),
                                      _SmallStat(
                                        icon: Icons.task_rounded,
                                        value: '${p['task_count'] ?? 0}',
                                        label: 'Milestones',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _SmallStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: scheme.outline),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w900, color: scheme.primary, fontSize: 13),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }
}

class _EmptyPrograms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_ind_rounded, size: 64, color: scheme.outline),
          const SizedBox(height: 16),
          Text(
            'No programs assigned',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Contact Administrator to get started.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
