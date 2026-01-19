import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class NotificationsScreen extends StatefulWidget {
  final ApiClient api;

  const NotificationsScreen({super.key, required this.api});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
      final json = await widget.api.get('/notifications', auth: true, query: {'limit': '50', 'offset': '0'});
      final items = (json as Map<String, dynamic>)['items'] as List<dynamic>;
      setState(() => _items = items.cast<Map<String, dynamic>>());
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load', message: e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  Future<void> _markReadLocal(String id) async {
    try {
      await widget.api.post('/notifications/$id/read', auth: true);
      if (!mounted) return;
      setState(() {
        _items = _items
            .map((n) => (n['id']?.toString() == id)
                ? {
                    ...n,
                    'read_at': DateTime.now().toUtc().toIso8601String(),
                  }
                : n)
            .toList();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppSnack(context, e.message);
    }
  }

  Future<void> _openNotification(Map<String, dynamic> n) async {
    final id = n['id']?.toString();
    final title = n['title']?.toString() ?? 'Notification';
    final body = n['body']?.toString() ?? '';
    final createdAt = n['created_at']?.toString();

    final when = (createdAt == null || createdAt.isEmpty) ? '' : '\n\nCreated: $createdAt';
    try {
      await showAppInfoPopup(context, title: title, message: '$body$when');
    } catch (_) {
      if (!mounted) return;
      showAppSnack(context, 'Unable to open notification');
      return;
    }

    if (!mounted) return;
    if (id != null && n['read_at'] == null) {
      await _markReadLocal(id);
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
          'Notifications',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: [
          if (items.any((n) => n['read_at'] == null))
            TextButton(
              onPressed: () async {
                final unreadIds = items.where((n) => n['read_at'] == null).map((n) => n['id'] as String).toList();
                for (final id in unreadIds) {
                  await _markReadLocal(id);
                }
              },
              child: const Text('Read All'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: items.isEmpty
                  ? _EmptyNotifications()
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: items.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final n = items[i];
                        final readAt = n['read_at'];
                        final isUnread = readAt == null;
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isUnread ? scheme.primary.withValues(alpha: 0.1) : scheme.outlineVariant,
                              width: isUnread ? 1.5 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _openNotification(n),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Leading Icon/Dot
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isUnread ? scheme.primary.withValues(alpha: 0.1) : scheme.surfaceContainerHigh,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isUnread ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                                      color: isUnread ? scheme.primary : scheme.outline,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                n['title']?.toString() ?? 'Update',
                                                style: textTheme.titleSmall?.copyWith(
                                                  fontWeight: isUnread ? FontWeight.w900 : FontWeight.w700,
                                                  color: isUnread ? scheme.onSurface : scheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                            if (isUnread)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: scheme.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          n['body']?.toString() ?? '',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
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

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_rounded, size: 32, color: scheme.outline),
          ),
          const SizedBox(height: 20),
          Text(
            'All Caught Up!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'New updates about your tasks and programs will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
