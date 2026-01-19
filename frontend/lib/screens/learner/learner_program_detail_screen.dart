import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class LearnerProgramDetailScreen extends StatefulWidget {
  final ApiClient api;
  final String programId;
  final Future<void> Function(String taskId) openTask;

  const LearnerProgramDetailScreen({
    super.key,
    required this.api,
    required this.programId,
    required this.openTask,
  });

  @override
  State<LearnerProgramDetailScreen> createState() => _LearnerProgramDetailScreenState();
}

class _LearnerProgramDetailScreenState extends State<LearnerProgramDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _progress;
  List<Map<String, dynamic>> _milestones = const [];

  bool _loadingReview = false;
  bool _submittingReview = false;
  Map<String, dynamic>? _reviewStatus;
  int _reviewRating = 5;
  final TextEditingController _reviewController = TextEditingController();

  static const _pageSize = 20;
  final Map<String?, _ModuleTasksState> _moduleTasks = {};
  final Map<String, _ModuleChaptersState> _moduleChapters = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final progress = await widget.api.get('/learner/programs/${widget.programId}/progress');
      final milestones = await widget.api.get('/learner/programs/${widget.programId}/milestones');

      final milestonesFull = milestones as Map<String, dynamic>;
      final milestoneItems = (milestonesFull['items'] as List).cast<Map<String, dynamic>>();

      final List<String> activeModuleIds = _moduleTasks.entries
          .where((e) => e.value.loadedOnce && e.key != null)
          .map((e) => e.key!)
          .toList();
      final bool generalWasLoaded = _moduleTasks[null]?.loadedOnce ?? false;

      setState(() {
        _progress = progress as Map<String, dynamic>;
        _milestones = milestoneItems;

        _moduleTasks.clear();
        _moduleChapters.clear();
        _moduleTasks[null] = _ModuleTasksState();
        for (final m in _milestones) {
          final id = m['id'] as String;
          _moduleTasks[id] = _ModuleTasksState();
          _moduleChapters[id] = _ModuleChaptersState();
        }
      });

      if (generalWasLoaded) _loadModuleTasks(null, reset: true);
      for (final id in activeModuleIds) {
        _loadModuleTasks(id, reset: true);
        _loadModuleChapters(id);
      }

      await _loadReviewIfEligible();
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load program', message: e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadReviewIfEligible() async {
    final completion = (_progress?['completionPercentage'] as num?)?.toInt() ?? 0;
    if (completion < 100) {
      if (mounted) {
        setState(() {
          _reviewStatus = null;
          _loadingReview = false;
        });
      }
      return;
    }

    setState(() => _loadingReview = true);
    try {
      final json = await widget.api.get('/learner/programs/${widget.programId}/review');
      if (!mounted) return;
      setState(() => _reviewStatus = json as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load review', message: e.message);
    } finally {
      if (mounted) setState(() => _loadingReview = false);
    }
  }

  Future<void> _submitReview() async {
    final feedback = _reviewController.text.trim();
    setState(() => _submittingReview = true);
    try {
      await widget.api.post(
        '/learner/programs/${widget.programId}/review',
        body: {
          'rating': _reviewRating,
          'feedback': feedback,
        },
      );
      if (!mounted) return;
      await showAppInfoPopup(context, title: 'Thanks!', message: 'Your program review was submitted.');
      await _loadReviewIfEligible();
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to submit review', message: e.message);
    } finally {
      if (mounted) setState(() => _submittingReview = false);
    }
  }

  Future<void> _loadModuleTasks(String? moduleId, {required bool reset}) async {
    final state = _moduleTasks[moduleId];
    if (state == null) return;
    if (state.loadingMore) return;
    if (!reset && !state.hasMore) return;

    setState(() {
      if (reset) {
        state.loading = true;
      } else {
        state.loadingMore = true;
      }
    });

    try {
      final nextOffset = reset ? 0 : state.offset;
      final query = <String, String>{
        'limit': '$_pageSize',
        'offset': '$nextOffset',
      };
      if (moduleId != null) query['milestoneId'] = moduleId;

      final json = await widget.api.get('/learner/programs/${widget.programId}/tasks', query: query);
      final items = ((json as Map<String, dynamic>)['items'] as List).cast<Map<String, dynamic>>();

      if (!mounted) return;
      setState(() {
        if (reset) state.items.clear();
        state.items.addAll(items);
        state.offset = nextOffset + items.length;
        state.hasMore = items.length == _pageSize;
        state.loadedOnce = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load deliverables', message: e.message);
    } finally {
      if (mounted) {
        setState(() {
          state.loading = false;
          state.loadingMore = false;
        });
      }
    }
  }

  Future<void> _loadModuleChapters(String moduleId) async {
    final state = _moduleChapters[moduleId];
    if (state == null) return;
    if (state.loading || state.loadedOnce) return;

    setState(() => state.loading = true);
    try {
      final json = await widget.api.get('/learner/programs/${widget.programId}/modules/$moduleId/chapters');
      final items = ((json as Map<String, dynamic>)['items'] as List).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        state.items
          ..clear()
          ..addAll(items);
        state.loadedOnce = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load chapters', message: e.message);
    } finally {
      if (mounted) setState(() => state.loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stats = _progress;
    final completionInt = (stats?['completionPercentage'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text(
          'Learning Journey',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                   // High-level stats header
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatCard(
                          label: 'Total Tasks',
                          value: '${stats?['total_tasks'] ?? 0}',
                          icon: Icons.assignment_outlined,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Approved',
                          value: '${stats?['approved'] ?? 0}',
                          icon: Icons.check_circle_outline_rounded,
                          color: scheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Completion',
                          value: '$completionInt%',
                          icon: Icons.auto_awesome_outlined,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  Text(
                    'Program Modules',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  if (_milestones.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: const Center(child: Text('No modules available yet.')),
                    )
                  else
                    ..._milestones.asMap().entries.map((entry) {
                      final i = entry.key;
                      final m = entry.value;
                      final moduleId = m['id'] as String;
                      final moduleTitle = m['title']?.toString() ?? 'Module ${i + 1}';

                      final tasksState = _moduleTasks[moduleId];
                      final chaptersState = _moduleChapters[moduleId];

                      final taskItems = tasksState?.items ?? const <Map<String, dynamic>>[];
                      final approvedCount = taskItems.where((t) => (t['submission_status']?.toString() ?? '') == 'approved').length;
                      final totalCount = taskItems.length;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: scheme.primary.withValues(alpha: 0.1),
                                child: Text('${i + 1}', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(moduleTitle, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              subtitle: (tasksState?.loadedOnce ?? false)
                                  ? Text('$approvedCount/$totalCount deliverables approved', style: textTheme.bodySmall)
                                  : const Text('Tap to explore content', style: TextStyle(fontSize: 12)),
                              onExpansionChanged: (expanded) {
                                if (!expanded) return;
                                if (chaptersState != null && !chaptersState.loadedOnce && !chaptersState.loading) {
                                  _loadModuleChapters(moduleId);
                                }
                                if (tasksState != null && !tasksState.loadedOnce && !tasksState.loading) {
                                  _loadModuleTasks(moduleId, reset: true);
                                }
                              },
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Divider(),
                                      const SizedBox(height: 12),
                                      _buildSectionHeader(context, 'Chapters', Icons.menu_book_rounded),
                                      const SizedBox(height: 12),
                                      if (chaptersState?.loading == true && chaptersState?.items.isEmpty == true)
                                        const Center(child: CircularProgressIndicator())
                                      else if (chaptersState?.loadedOnce == true && chaptersState?.items.isEmpty == true)
                                        const Text('No technical chapters found.', style: TextStyle(fontStyle: FontStyle.italic))
                                      else
                                        ...chaptersState!.items.map((ch) => _ChapterCard(ch: ch)),

                                      const SizedBox(height: 24),
                                      _buildSectionHeader(context, 'Deliverables', Icons.task_alt_rounded),
                                      const SizedBox(height: 12),
                                      if (tasksState?.loading == true && tasksState?.items.isEmpty == true)
                                        const Center(child: CircularProgressIndicator())
                                      else if (tasksState?.loadedOnce == true && tasksState?.items.isEmpty == true)
                                        const Text('No deliverables required.', style: TextStyle(fontStyle: FontStyle.italic))
                                      else
                                        ...tasksState!.items.map((t) => _TaskTile(
                                              t: t,
                                              onTap: (taskId) async {
                                                await widget.openTask(taskId);
                                                _load(); // Refresh stats and statuses on return
                                              },
                                            )),

                                      if (tasksState?.hasMore == true)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12),
                                          child: TextButton(
                                            onPressed: tasksState?.loadingMore == true ? null : () => _loadModuleTasks(moduleId, reset: false),
                                            child: Text(tasksState?.loadingMore == true ? 'Loading...' : 'Show More Tasks'),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 32),
                  Text(
                    'Program Feedback',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  if (completionInt < 100)
                    _InfoBanner(
                      message: 'Complete all requirements (100%) to unlock program feedback. Current: $completionInt%',
                      icon: Icons.lock_outline_rounded,
                    )
                  else if (_loadingReview)
                    const Center(child: CircularProgressIndicator())
                  else
                    _ProgramReviewCard(
                      status: _reviewStatus,
                      rating: _reviewRating,
                      onRatingChanged: (v) => setState(() => _reviewRating = v),
                      controller: _reviewController,
                      submitting: _submittingReview,
                      onSubmit: _submitReview,
                    ),
                   const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: scheme.primary,
                letterSpacing: 1.1,
              ),
        ),
      ],
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Map<String, dynamic> ch;
  const _ChapterCard({required this.ch});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final title = ch['title']?.toString() ?? 'Untitled Chapter';
    final bodyMd = ch['body_md']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          MarkdownBody(
            data: bodyMd,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: textTheme.bodyMedium?.copyWith(height: 1.6, color: scheme.onSurfaceVariant),
              h1: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              code: TextStyle(backgroundColor: scheme.surface, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Map<String, dynamic> t;
  final ValueChanged<String> onTap;
  const _TaskTile({required this.t, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = t['submission_status']?.toString() ?? 'not_submitted';
    final deadline = t['deadline_at']?.toString();

    final statusColor = switch (status) {
      'approved' => Colors.green,
      'pending' || 'submitted' => Colors.orange,
      'rejected' => Colors.red,
      _ => scheme.onSurfaceVariant,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => onTap(t['id'] as String),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['title']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                          ),
                          if (deadline != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.timer_outlined, size: 12, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(deadline, style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: scheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  const _InfoBanner({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.secondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.secondary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramReviewCard extends StatelessWidget {
  final Map<String, dynamic>? status;
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onSubmit;

  const _ProgramReviewCard({
    required this.status,
    required this.rating,
    required this.onRatingChanged,
    required this.controller,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (status == null) return const _InfoBanner(message: 'Loading review eligibility...', icon: Icons.refresh_rounded);

    final review = (status?['review'] as Map?)?.cast<String, dynamic>();
    if (review != null) {
      final r = (review['rating'] as num?)?.toInt() ?? 0;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: scheme.outlineVariant)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YOUR REVIEW', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary)),
            const SizedBox(height: 12),
            Row(children: [for (int i = 0; i < 5; i++) Icon(i < r ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber, size: 20)]),
            if (review['feedback'] != null) ...[const SizedBox(height: 12), Text(review['feedback'], style: textTheme.bodyMedium)],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(28), border: Border.all(color: scheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           const Text('How was your experience?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
           const SizedBox(height: 16),
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [for (int i = 1; i <= 5; i++) IconButton(
               onPressed: () => onRatingChanged(i),
               icon: Icon(i <= rating ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber, size: 36),
             )],
           ),
           const SizedBox(height: 16),
           TextField(
             controller: controller,
             minLines: 3,
             maxLines: 5,
             decoration: const InputDecoration(hintText: 'Share your thoughts on this program...', labelText: 'Feedback'),
           ),
           const SizedBox(height: 24),
           FilledButton(
             onPressed: submitting ? null : onSubmit,
             child: submitting ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Submit Feedback'),
           ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: scheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ModuleTasksState {
  final List<Map<String, dynamic>> items = [];
  int offset = 0;
  bool hasMore = true;
  bool loading = false;
  bool loadingMore = false;
  bool loadedOnce = false;
}

class _ModuleChaptersState {
  final List<Map<String, dynamic>> items = [];
  bool loading = false;
  bool loadedOnce = false;
}


