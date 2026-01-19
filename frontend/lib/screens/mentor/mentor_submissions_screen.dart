import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class MentorSubmissionsScreen extends StatefulWidget {
  final ApiClient api;
  final Future<void> Function(String submissionId) openReview;

  const MentorSubmissionsScreen({
    super.key,
    required this.api,
    required this.openReview,
  });

  @override
  State<MentorSubmissionsScreen> createState() => _MentorSubmissionsScreenState();
}

class _MentorSubmissionsScreenState extends State<MentorSubmissionsScreen> {
  static const _pageSize = 20;

  String? _status = 'submitted';

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
      final query = <String, String>{
        'limit': '$_pageSize',
        'offset': '$nextOffset',
      };
      if (_status != null) query['status'] = _status!;

      final json = await widget.api.get('/mentor/submissions', query: query);
      final items = ((json as Map<String, dynamic>)['items'] as List).cast<Map<String, dynamic>>();

      setState(() {
        if (reset) _items.clear();
        _items.addAll(items);
        _offset = nextOffset + items.length;
        _hasMore = items.length == _pageSize;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load submissions', message: e.message);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _setStatus(String? status) {
    setState(() => _status = status);
    _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text(
          'Review Queue',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 64,
            width: double.infinity,
            color: scheme.surface,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(label: 'All Tasks', selected: _status == null, onTap: () => _setStatus(null)),
                const SizedBox(width: 8),
                _FilterChip(label: 'Submitted', selected: _status == 'submitted', onTap: () => _setStatus('submitted')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Pending Approval', selected: _status == 'approved', onTap: () => _setStatus('approved')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Follow Up', selected: _status == 'rejected', onTap: () => _setStatus('rejected')),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _load(reset: true),
                    child: _items.isEmpty
                        ? _EmptySubmissions(status: _status)
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

                              final s = _items[i];
                              final status = s['status']?.toString() ?? 'submitted';
                              final learnerName = s['learner_name']?.toString() ?? 'Learner';
                              final initial = learnerName.isNotEmpty ? learnerName[0].toUpperCase() : '?';

                              final statusColor = switch (status) {
                                'approved' => Colors.green,
                                'submitted' => scheme.primary,
                                'rejected' => Colors.redAccent,
                                _ => scheme.outline,
                              };

                              return Container(
                                decoration: BoxDecoration(
                                  color: scheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: scheme.outlineVariant),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    final id = s['id'] as String?;
                                    if (id == null) return;
                                    await widget.openReview(id);
                                    if (!mounted) return;
                                    _load(reset: true);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: scheme.primary.withValues(alpha: 0.1),
                                          child: Text(
                                            initial,
                                            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                s['task_title']?.toString() ?? 'Untitled Task',
                                                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'From: $learnerName',
                                                style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                              ),
                                              const SizedBox(height: 8),
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
                                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: scheme.outline),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _EmptySubmissions extends StatelessWidget {
  final String? status;
  const _EmptySubmissions({this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_rounded, size: 64, color: scheme.outline),
          const SizedBox(height: 16),
          Text(
            'No submissions found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'All caught up for ${status ?? 'all'} status.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
