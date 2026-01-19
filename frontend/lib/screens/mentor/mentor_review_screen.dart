import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class MentorReviewScreen extends StatefulWidget {
  final ApiClient api;
  final String submissionId;

  const MentorReviewScreen({super.key, required this.api, required this.submissionId});

  @override
  State<MentorReviewScreen> createState() => _MentorReviewScreenState();
}

class _MentorReviewScreenState extends State<MentorReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedback = TextEditingController();
  final _score = TextEditingController();

  String _decision = 'approved';
  bool _submitting = false;
  bool _editing = false;

  bool _loading = true;
  Map<String, dynamic>? _submission;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final json = await widget.api.get('/mentor/submissions/${widget.submissionId}');
      final submission = (json as Map<String, dynamic>)['submission'] as Map<String, dynamic>;

      final status = submission['status']?.toString();
      final decision = (status == 'approved' || status == 'rejected') ? status! : 'approved';

      setState(() {
        _submission = submission;
        _decision = decision;
        _editing = false;
      });

      if (_feedback.text.trim().isEmpty) {
        _feedback.text = submission['feedback_text']?.toString() ?? '';
      }
      if (_score.text.trim().isEmpty) {
        final score = submission['score'];
        if (score != null) _score.text = score.toString();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load submission', message: e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _feedback.dispose();
    _score.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final score = _score.text.trim().isEmpty ? null : int.parse(_score.text.trim());
      await widget.api.post(
        '/mentor/submissions/${widget.submissionId}/review',
        body: {
          'decision': _decision,
          'feedbackText': _feedback.text.trim(),
          'score': score,
        },
      );
      if (!mounted) return;
      showAppSnack(context, 'Review saved');
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Review failed', message: e.message);
    } catch (_) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Review failed', message: 'Invalid score or request');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _submission;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text(
          'Evaluate Deliverable',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filledTonal(
              onPressed: _loading ? null : () => setState(() => _editing = !_editing),
              icon: Icon(_editing ? Icons.visibility_rounded : Icons.edit_rounded, size: 20),
              tooltip: _editing ? 'Switch to View' : 'Switch to Edit',
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
                  if (s != null) ...[
                    // Submission Content Card
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.description_rounded, color: scheme.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s['task_title']?.toString() ?? 'Untitled Task',
                                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      'Submitted by ${s['learner_name'] ?? 'Learner'}',
                                      style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          if ((s['link'] ?? '').toString().isNotEmpty) ...[
                            Text('SUBMISSION LINK', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary)),
                            const SizedBox(height: 4),
                            Text(
                              s['link'].toString(),
                              style: textTheme.bodyMedium?.copyWith(color: scheme.primary, decoration: TextDecoration.underline),
                            ),
                          ],
                          if ((s['notes'] ?? '').toString().isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text('LEARNER NOTES', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary)),
                            const SizedBox(height: 4),
                            Text(s['notes'].toString(), style: textTheme.bodyMedium),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Review Form Header
                  Row(
                    children: [
                      Icon(Icons.rate_review_rounded, size: 16, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'YOUR EVALUATION',
                        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary, letterSpacing: 1.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: _editing ? scheme.primary.withValues(alpha: 0.3) : scheme.outlineVariant),
                      boxShadow: _editing ? [BoxShadow(color: scheme.primary.withValues(alpha: 0.05), blurRadius: 20)] : null,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Decision Selector
                          Text('Verdict', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'approved', label: Text('Approve'), icon: Icon(Icons.check_circle_rounded)),
                              ButtonSegment(value: 'rejected', label: Text('Request Changes'), icon: Icon(Icons.history_rounded)),
                            ],
                            selected: {_decision},
                            onSelectionChanged: _editing ? (vals) => setState(() => _decision = vals.first) : null,
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: _decision == 'approved' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                              selectedForegroundColor: _decision == 'approved' ? Colors.green : Colors.red,
                              side: BorderSide(color: scheme.outlineVariant),
                            ),
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _score,
                            keyboardType: TextInputType.number,
                            enabled: _editing,
                            decoration: const InputDecoration(
                              labelText: 'Final Score (0-100)',
                              hintText: 'Rate performance...',
                              prefixIcon: Icon(Icons.auto_awesome_rounded),
                            ),
                            validator: (v) {
                              final value = (v ?? '').trim();
                              if (value.isEmpty) return null;
                              final parsed = int.tryParse(value);
                              if (parsed == null) return 'Enter a number';
                              if (parsed < 0 || parsed > 100) return '0 to 100 only';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _feedback,
                            minLines: 4,
                            maxLines: 8,
                            enabled: _editing,
                            decoration: const InputDecoration(
                              labelText: 'Mentor Feedback',
                              hintText: 'Share constructive insights...',
                              prefixIcon: Icon(Icons.notes_rounded),
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 32),

                          if (_editing)
                            SizedBox(
                              height: 56,
                              child: FilledButton(
                                onPressed: _submitting ? null : _submit,
                                child: _submitting
                                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                    : const Text('Complete Evaluation'),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 16, color: scheme.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Review is in view-only mode. Use the edit icon above to make changes.',
                                      style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
