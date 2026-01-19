import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class LearnerProgramsScreen extends StatefulWidget {
  final ApiClient api;
  final void Function(String programId) openProgram;

  const LearnerProgramsScreen({
    super.key,
    required this.api,
    required this.openProgram,
  });

  @override
  State<LearnerProgramsScreen> createState() => _LearnerProgramsScreenState();
}

class _LearnerProgramsScreenState extends State<LearnerProgramsScreen> {
  static const _pageSize = 20;

  // Enrolled programs
  bool _loadingEnrolled = true;
  bool _loadingMoreEnrolled = false;
  bool _hasMoreEnrolled = true;
  int _offsetEnrolled = 0;
  final List<Map<String, dynamic>> _enrolled = [];

  // Available programs (not enrolled)
  bool _loadingAvailable = false;
  bool _loadingMoreAvailable = false;
  bool _hasMoreAvailable = true;
  int _offsetAvailable = 0;
  final List<Map<String, dynamic>> _available = [];

  final Set<String> _enrolling = {};

  @override
  void initState() {
    super.initState();
    _loadEnrolled(reset: true);
  }

  Future<void> _loadEnrolled({required bool reset}) async {
    if (_loadingMoreEnrolled) return;
    if (!reset && !_hasMoreEnrolled) return;

    setState(() {
      if (reset) {
        _loadingEnrolled = true;
      } else {
        _loadingMoreEnrolled = true;
      }
    });

    try {
      final nextOffset = reset ? 0 : _offsetEnrolled;
      final json = await widget.api.get(
        '/learner/programs',
        query: {
          'limit': '$_pageSize',
          'offset': '$nextOffset',
        },
      );
      final items = ((json as Map<String, dynamic>)['items'] as List).cast<Map<String, dynamic>>();

      setState(() {
        if (reset) _enrolled.clear();
        _enrolled.addAll(items);
        _offsetEnrolled = nextOffset + items.length;
        _hasMoreEnrolled = items.length == _pageSize;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load programs', message: e.message);
    } finally {
      if (mounted) {
        setState(() {
          _loadingEnrolled = false;
          _loadingMoreEnrolled = false;
        });
      }
    }
  }

  Future<void> _loadAvailable({required bool reset}) async {
    if (_loadingMoreAvailable) return;
    if (!reset && !_hasMoreAvailable) return;

    setState(() {
      if (reset) {
        _loadingAvailable = true;
      } else {
        _loadingMoreAvailable = true;
      }
    });

    try {
      final nextOffset = reset ? 0 : _offsetAvailable;
      final json = await widget.api.get(
        '/learner/programs/available',
        query: {
          'limit': '$_pageSize',
          'offset': '$nextOffset',
        },
      );
      final items = ((json as Map<String, dynamic>)['items'] as List).cast<Map<String, dynamic>>();

      setState(() {
        if (reset) _available.clear();
        _available.addAll(items);
        _offsetAvailable = nextOffset + items.length;
        _hasMoreAvailable = items.length == _pageSize;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load available programs', message: e.message);
    } finally {
      if (mounted) {
        setState(() {
          _loadingAvailable = false;
          _loadingMoreAvailable = false;
        });
      }
    }
  }

  Future<void> _enroll(String programId) async {
    if (_enrolling.contains(programId)) return;
    setState(() => _enrolling.add(programId));
    try {
      await widget.api.post('/learner/programs/$programId/enroll');
      if (!mounted) return;
      await showAppInfoPopup(
        context,
        title: 'Enrolled',
        message: 'You are now enrolled in this program.',
      );
      await _loadEnrolled(reset: true);
      await _loadAvailable(reset: true);
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Enroll failed', message: e.message);
    } catch (_) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Enroll failed', message: 'Something went wrong.');
    } finally {
      if (mounted) setState(() => _enrolling.remove(programId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: scheme.surfaceContainerHigh,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          title: Text(
            'Explore Programs',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          bottom: TabBar(
            onTap: (index) {
              if (index == 1 && _available.isEmpty && !_loadingAvailable) {
                _loadAvailable(reset: true);
              }
            },
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 4,
            indicatorColor: scheme.primary,
            labelColor: scheme.primary,
            unselectedLabelColor: scheme.onSurfaceVariant,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            tabs: const [
              Tab(text: 'My Journey'),
              Tab(text: 'Catalog'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEnrolledTab(),
            _buildAvailableTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrolledTab() {
    if (_loadingEnrolled) return const Center(child: CircularProgressIndicator());
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_enrolled.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories_outlined, size: 80, color: scheme.primary.withValues(alpha: 0.2)),
            const SizedBox(height: 24),
            Text(
              'No active programs',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore the catalog to start your learning journey.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => DefaultTabController.of(context).animateTo(1),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Browse Catalog'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadEnrolled(reset: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _enrolled.length + (_hasMoreEnrolled ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (ctx, i) {
          if (i == _enrolled.length) {
            if (!_loadingMoreEnrolled) _loadEnrolled(reset: false);
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final p = _enrolled[i];
          return _ProgramCard(
            title: p['title']?.toString() ?? '',
            description: p['description']?.toString() ?? '',
            isEnrolled: true,
            onTap: () => widget.openProgram(p['id'] as String),
          );
        },
      ),
    );
  }

  Widget _buildAvailableTab() {
    if (_loadingAvailable) return const Center(child: CircularProgressIndicator());
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_available.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadAvailable(reset: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 80, color: scheme.primary.withValues(alpha: 0.2)),
                const SizedBox(height: 24),
                Text(
                  'All caught up!',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'No new available programs right now. Check back later!',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadAvailable(reset: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _available.length + (_hasMoreAvailable ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (ctx, i) {
          if (i == _available.length) {
            if (!_loadingMoreAvailable) _loadAvailable(reset: false);
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final p = _available[i];
          final programId = p['id'] as String;
          final enrolling = _enrolling.contains(programId);
          final mentorName = (p['mentor_name'] ?? p['mentorName'])?.toString();

          return _ProgramCard(
            title: p['title']?.toString() ?? '',
            description: p['description']?.toString() ?? '',
            mentorName: mentorName,
            isEnrolled: false,
            enrolling: enrolling,
            onEnroll: () => _enroll(programId),
            onTap: () async {
              await showAppInfoPopup(
                context,
                title: 'Program Preview',
                message: 'Enroll to access course materials, tasks, and connect with your mentor.',
                primaryButtonText: 'Got it',
              );
            },
          );
        },
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final String title;
  final String description;
  final String? mentorName;
  final bool isEnrolled;
  final bool enrolling;
  final VoidCallback onTap;
  final VoidCallback? onEnroll;

  const _ProgramCard({
    required this.title,
    required this.description,
    this.mentorName,
    required this.isEnrolled,
    this.enrolling = false,
    required this.onTap,
    this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isEnrolled ? scheme.secondary : scheme.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isEnrolled ? Icons.assignment_turned_in_rounded : Icons.library_add_rounded,
                      color: isEnrolled ? scheme.secondary : scheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: scheme.onSurface),
                        ),
                        if (mentorName != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person_pin_rounded, size: 14, color: scheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                mentorName!,
                                style: textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isEnrolled && onEnroll != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: enrolling ? null : onEnroll,
                    child: enrolling
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Start Learning'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
