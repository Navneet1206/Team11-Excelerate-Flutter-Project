import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class ProgramReviewsScreen extends StatefulWidget {
  final ApiClient api;
  final String title;
  final String endpointPath;

  const ProgramReviewsScreen({
    super.key,
    required this.api,
    required this.title,
    required this.endpointPath,
  });

  @override
  State<ProgramReviewsScreen> createState() => _ProgramReviewsScreenState();
}

class _ProgramReviewsScreenState extends State<ProgramReviewsScreen> {
  static const _pageSize = 20;

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;

  Map<String, dynamic>? _summary;
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
      final json = await widget.api.get(
        widget.endpointPath,
        query: {
          'limit': '$_pageSize',
          'offset': '$nextOffset',
        },
      );

      final map = json as Map<String, dynamic>;
      final items = ((map['items'] ?? []) as List).cast<Map<String, dynamic>>();
      final summary = (map['summary'] as Map?)?.cast<String, dynamic>();

      if (!mounted) return;
      setState(() {
        _summary = summary;
        if (reset) _items.clear();
        _items.addAll(items);
        _offset = nextOffset + items.length;
        _hasMore = items.length == _pageSize;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load reviews', message: e.message);
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

    final totalReviews = _summary?['totalReviews']?.toString() ?? '0';
    final averageRating = _summary?['averageRating']?.toString() ?? '0.00';

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text(
          'Sentiment Analysis',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  Row(
                    children: [
                      Expanded(child: _SummaryCard(label: 'Entries', value: totalReviews, icon: Icons.forum_rounded, color: scheme.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _SummaryCard(label: 'Avg Score', value: averageRating, icon: Icons.star_rounded, color: scheme.secondary)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Icon(Icons.feedback_rounded, size: 16, color: scheme.outline),
                      const SizedBox(width: 12),
                      Text(
                        'LEARNER FEEDBACK',
                        style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900, color: scheme.outline, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_items.isEmpty)
                    _EmptyReviews()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length + (_hasMore ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == _items.length) {
                          if (!_loadingMore) _load(reset: false);
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final r = _items[index];
                        final name = r['learner_name']?.toString() ?? 'Anonymous';
                        final rating = (r['rating'] as num?)?.toInt() ?? 0;
                        final feedback = r['feedback']?.toString() ?? '';

                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: scheme.primary.withValues(alpha: 0.1),
                                    child: Text(name[0].toUpperCase(), style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                        Text(r['learner_email']?.toString() ?? '', style: textTheme.bodySmall?.copyWith(color: scheme.outline)),
                                      ],
                                    ),
                                  ),
                                  _StarRating(rating: rating),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                feedback.trim().isEmpty ? 'No qualitative feedback provided.' : feedback,
                                style: textTheme.bodyMedium?.copyWith(height: 1.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                r['created_at']?.toString() ?? '',
                                style: textTheme.bodySmall?.copyWith(color: scheme.outline, fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 16,
          color: i < rating ? Colors.amber : Theme.of(context).colorScheme.outlineVariant,
        );
      }),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          Text(label.toUpperCase(), style: TextStyle(color: scheme.outline, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(28), border: Border.all(color: scheme.outlineVariant)),
      child: Column(
        children: [
          Icon(Icons.rate_review_rounded, size: 48, color: scheme.outline),
          const SizedBox(height: 16),
          Text('No Sentiment Yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Feedback from learners will show up here.', style: TextStyle(color: scheme.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
