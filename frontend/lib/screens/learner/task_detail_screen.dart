import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class TaskDetailScreen extends StatefulWidget {
  final ApiClient api;
  final String taskId;

  const TaskDetailScreen({super.key, required this.api, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _task;

  final _formKey = GlobalKey<FormState>();
  final _link = TextEditingController();
  final _notes = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _link.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final json = await widget.api.get('/learner/tasks/${widget.taskId}');
      final task = (json as Map<String, dynamic>)['task'] as Map<String, dynamic>;
      setState(() {
        _task = task;
        _link.text = (task['submission_link'] as String?) ?? '';
        _notes.text = (task['submission_notes'] as String?) ?? '';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load task', message: e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _submitting = true);
    try {
      var link = _link.text.trim();
      if (link.isNotEmpty && !link.startsWith('http://') && !link.startsWith('https://')) {
        link = 'https://$link';
      }
      await widget.api.post(
        '/learner/tasks/${widget.taskId}/submit',
        body: {
          'link': link,
          'notes': _notes.text.trim(),
        },
      );
      if (!mounted) return;
      showAppSnack(context, 'Submitted');
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Submission failed', message: e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final task = _task;
    if (task == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Task not found')),
      );
    }

    final links = (task['resource_links'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    final submissionStatus = task['submission_status']?.toString() ?? 'not_submitted';
    final hasSubmitted = submissionStatus != 'not_submitted' && submissionStatus.isNotEmpty;
    final feedback = task['feedback_text']?.toString();
    final score = task['score']?.toString();
    final submittedLink = task['submission_link']?.toString();
    final submittedNotes = task['submission_notes']?.toString();
    final deadline = task['deadline_at']?.toString() ?? 'No deadline';

    final statusColor = switch (submissionStatus) {
      'approved' => Colors.green,
      'pending' || 'submitted' => Colors.orange,
      'rejected' => Colors.red,
      _ => scheme.outline,
    };

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text(
          'Deliverable',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Task Title & Description Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        submissionStatus.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.event_available_rounded, size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      deadline,
                      style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  task['title']?.toString() ?? 'Untitled Task',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  task['description']?.toString() ?? '',
                  style: textTheme.bodyMedium?.copyWith(height: 1.6, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Resources Section
          _buildSectionHeader(context, 'Learning Resources', Icons.library_books_rounded),
          const SizedBox(height: 12),
          if (links.isEmpty)
            _EmptyState(message: 'No extra resources provided.', icon: Icons.link_off_rounded)
          else
            ...links.map((l) => _ResourceCard(link: l)),

          const SizedBox(height: 32),

          // Submission Section
          _buildSectionHeader(context, 'Your Submission', Icons.upload_file_rounded),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (score != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Submission Score', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        score,
                        style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                ],

                if (hasSubmitted) ...[
                  if (submittedLink != null && submittedLink.isNotEmpty) ...[
                    Text('SUBMITTED LINK', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              submittedLink,
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: submittedLink));
                              showAppSnack(context, 'Link copied');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (submittedNotes != null && submittedNotes.trim().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('SUBMISSION NOTES', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary)),
                    const SizedBox(height: 8),
                    Text(submittedNotes, style: textTheme.bodyMedium),
                  ],
                  if (feedback != null && feedback.trim().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.feedback_outlined, size: 16, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('MENTOR FEEDBACK', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(feedback, style: const TextStyle(fontSize: 13, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const _InfoBanner(
                    message: 'Your submission is now locked for review.',
                    icon: Icons.lock_outline_rounded,
                  ),
                ] else
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _link,
                          decoration: const InputDecoration(
                            labelText: 'Link to Deliverable',
                            hintText: 'e.g. GitHub repo, Drive folder...',
                            prefixIcon: Icon(Icons.link_rounded),
                          ),
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return 'Please provide a link';
                            if (!value.startsWith('http') && !value.startsWith('www.')) return 'Enter a valid URL';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _notes,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Submission Notes',
                            prefixIcon: Icon(Icons.description_outlined),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                : const Text('Confirm Submission'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
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

class _ResourceCard extends StatelessWidget {
  final String link;
  const _ResourceCard({required this.link});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ListTile(
        leading: const Icon(Icons.attachment_rounded, size: 20),
        title: Text(
          link,
          style: const TextStyle(fontSize: 13, decoration: TextDecoration.underline),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded, size: 18),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: link));
            showAppSnack(context, 'Link copied');
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: scheme.outline),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
        ],
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
        color: scheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
