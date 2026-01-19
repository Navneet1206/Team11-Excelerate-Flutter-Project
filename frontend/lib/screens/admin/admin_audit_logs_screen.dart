import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class AdminAuditLogsScreen extends StatefulWidget {
  final ApiClient api;

  const AdminAuditLogsScreen({super.key, required this.api});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
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
      final json = await widget.api.get('/admin/audit-logs', query: {
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
      await showAppErrorPopup(context, title: 'Failed to load audit logs', message: e.message);
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
          'System Audit Trail',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: _items.isEmpty
                  ? _EmptyLogs()
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

                        final al = _items[i];
                        final action = al['action']?.toString() ?? 'SYSTEM_EVENT';
                        final actor = al['actor_name'] ?? al['actor_user_id'] ?? 'System';

                        return Container(
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.history_toggle_off_rounded, color: scheme.primary, size: 20),
                            ),
                            title: Text(
                              action.replaceAll('_', ' ').toUpperCase(),
                              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline_rounded, size: 12, color: scheme.outline),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Actor: $actor',
                                          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    al['created_at']?.toString() ?? '',
                                    style: textTheme.bodySmall?.copyWith(color: scheme.outline, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: scheme.outline),
                            onTap: () => _openDetails(al),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Future<void> _openDetails(Map<String, dynamic> item) async {
    final meta = item['meta'];
    final metaText = meta == null ? '{}' : const JsonEncoder.withIndent('  ').convert(meta);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: scheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.description_rounded, color: scheme.secondary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Log Entry Detail',
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(label: 'Action Type', value: item['action']?.toString() ?? '-'),
              _DetailRow(label: 'Initiated By', value: item['actor_name'] ?? item['actor_user_id'] ?? 'System'),
              _DetailRow(label: 'Target Entity', value: '${item['entity_type'] ?? '-'} (${item['entity_id'] ?? 'N/A'})'),
              _DetailRow(label: 'Timestamp', value: item['created_at'] ?? '-'),
              const SizedBox(height: 20),
              Text(
                'METADATA PAYLOAD',
                style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: scheme.outline),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      metaText,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Dismiss View'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(color: scheme.outline, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyLogs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: scheme.outline),
          const SizedBox(height: 16),
          Text(
            'No audit logs found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'System history will appear here over time.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
