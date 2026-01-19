import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class AdminProgramDetailScreen extends StatefulWidget {
  final ApiClient api;
  final String programId;

  const AdminProgramDetailScreen({
    super.key,
    required this.api,
    required this.programId,
  });

  @override
  State<AdminProgramDetailScreen> createState() => _AdminProgramDetailScreenState();
}

class _AdminProgramDetailScreenState extends State<AdminProgramDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _program;
  List<Map<String, dynamic>> _learners = const [];
  List<Map<String, dynamic>> _milestones = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final json = await widget.api.get('/admin/programs/${widget.programId}');
      setState(() {
        _program = (json as Map<String, dynamic>)['program'] as Map<String, dynamic>;
        _learners = (json['learners'] as List).cast<Map<String, dynamic>>();
        _milestones = (json['milestones'] as List).cast<Map<String, dynamic>>();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load program', message: e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _assignLearner() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _AssignLearnerDialog(api: widget.api, programId: widget.programId),
    );

    if (!mounted) return;

    if (ok == true) {
      showAppSnack(context, 'Learner assigned');
      _load();
    }
  }

  Future<void> _createMilestone() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _CreateMilestoneDialog(api: widget.api, programId: widget.programId),
    );

    if (!mounted) return;

    if (ok == true) {
      showAppSnack(context, 'Milestone created');
      _load();
    }
  }

  Future<void> _createTask() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _CreateTaskDialog(api: widget.api, programId: widget.programId, milestones: _milestones),
    );

    if (!mounted) return;

    if (ok == true) {
      showAppSnack(context, 'Task created');
    }
  }

  Future<void> _changeMentor() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ChangeMentorDialog(api: widget.api, programId: widget.programId),
    );

    if (!mounted) return;

    if (ok == true) {
      showAppSnack(context, 'Mentor updated');
      _load();
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
          'Curriculum Insight',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filledTonal(
              tooltip: 'Cohort Analytics',
              onPressed: () => context.push('/admin/programs/${widget.programId}/reviews'),
              icon: const Icon(Icons.analytics_rounded, size: 20),
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
                  // Program Header Detail
                  Text(
                    _program?['title']?.toString().toUpperCase() ?? 'PROGRAM DETAIL',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 16),
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.school_rounded, color: scheme.primary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _program?['title']?.toString() ?? 'Learning Track',
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'MANAGEMENT HUB',
                          style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: scheme.outline, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ActionChip(
                              label: 'Add Learner',
                              icon: Icons.person_add_rounded,
                              onTap: _assignLearner,
                              color: scheme.primary,
                            ),
                            _ActionChip(
                              label: 'New Milestone',
                              icon: Icons.flag_rounded,
                              onTap: _createMilestone,
                              color: scheme.secondary,
                            ),
                            _ActionChip(
                              label: 'Add Task',
                              icon: Icons.playlist_add_rounded,
                              onTap: _createTask,
                              color: scheme.tertiary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  _SectionHeader(title: 'Program Mentor', icon: Icons.admin_panel_settings_rounded),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: scheme.secondary.withValues(alpha: 0.1),
                        child: Icon(Icons.person_pin_rounded, color: scheme.secondary),
                      ),
                      title: Text(
                        _program?['mentor_name']?.toString() ?? 'Unassigned',
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      subtitle: const Text('Primary Instructor'),
                      trailing: IconButton(
                        icon: const Icon(Icons.swap_horiz_rounded),
                        onPressed: _changeMentor,
                        tooltip: 'Change Mentor',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  _SectionHeader(title: 'Assigned Learners', icon: Icons.groups_rounded, count: _learners.length),
                  const SizedBox(height: 12),
                  if (_learners.isEmpty)
                    _EmptyHint(text: 'No learners enrolled in this program yet.', icon: Icons.person_off_rounded)
                  else
                    ..._learners.map((l) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: scheme.primary.withValues(alpha: 0.1),
                              child: Text(
                                (l['full_name']?.toString() ?? '?')[0].toUpperCase(),
                                style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(l['full_name']?.toString() ?? 'Learner', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                            subtitle: Text(l['email']?.toString() ?? '', style: textTheme.bodySmall),
                          ),
                        )),

                  const SizedBox(height: 32),
                  _SectionHeader(title: 'Curriculum Trail', icon: Icons.map_rounded, count: _milestones.length),
                  const SizedBox(height: 12),
                  if (_milestones.isEmpty)
                    _EmptyHint(text: 'Define your program milestones to structure the curriculum.', icon: Icons.timeline_rounded)
                  else
                    ..._milestones.map((m) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: scheme.secondary.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: Text('${m['sort_order'] ?? 0}', style: TextStyle(color: scheme.secondary, fontWeight: FontWeight.w900, fontSize: 12)),
                            ),
                            title: Text(m['title']?.toString() ?? 'Milestone', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                            subtitle: const Text('Program Core Phase'),
                            trailing: Icon(Icons.chevron_right_rounded, color: scheme.outline),
                          ),
                        )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _ActionChip({required this.label, required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int? count;
  const _SectionHeader({required this.title, required this.icon, this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.outline),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900, color: scheme.outline, letterSpacing: 0.5),
        ),
        if (count != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: scheme.outline.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: Text('$count', style: TextStyle(color: scheme.outline, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  final IconData icon;
  const _EmptyHint({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: scheme.outlineVariant)),
      child: Column(
        children: [
          Icon(icon, color: scheme.outline, size: 32),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
        ],
      ),
    );
  }
}

class _AssignLearnerDialog extends StatefulWidget {
  final ApiClient api;
  final String programId;

  const _AssignLearnerDialog({required this.api, required this.programId});

  @override
  State<_AssignLearnerDialog> createState() => _AssignLearnerDialogState();
}

class _AssignLearnerDialogState extends State<_AssignLearnerDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _loadingLearners = true;
  List<Map<String, dynamic>> _learners = const [];
  String? _learnerId;

  @override
  void initState() {
    super.initState();
    _loadLearners();
  }

  Future<void> _loadLearners() async {
    setState(() => _loadingLearners = true);
    try {
      final json = await widget.api.get('/admin/users', query: {'role': 'learner', 'limit': '50', 'offset': '0'});
      final items = ((json as Map<String, dynamic>)['items'] as List).cast<Map<String, dynamic>>();
      setState(() {
        _learners = items;
        _learnerId = items.isNotEmpty ? items.first['id'] as String : null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Network Error', message: e.message);
    } finally {
      if (mounted) setState(() => _loadingLearners = false);
    }
  }

  Future<void> _save() async {
    if (_learnerId == null) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.api.post('/admin/programs/${widget.programId}/assign-learner', body: {'learnerId': _learnerId});
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Assignment Failed', message: e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(32)),
        child: _loadingLearners
            ? const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()))
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Onboard Learner', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    Text('Select a learner to assign to this track.', style: textTheme.bodyMedium?.copyWith(color: scheme.outline)),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      initialValue: _learnerId,
                      items: _learners.map((u) => DropdownMenuItem(value: u['id'] as String, child: Text(u['full_name']?.toString() ?? u['email']?.toString() ?? ''))).toList(),
                      onChanged: (v) => setState(() => _learnerId = v),
                      decoration: const InputDecoration(labelText: 'Available Learners', prefixIcon: Icon(Icons.person_pin_rounded)),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(child: TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(false), child: const Text('Cancel'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _saving ? null : _save,
                            child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Assign'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ChangeMentorDialog extends StatefulWidget {
  final ApiClient api;
  final String programId;

  const _ChangeMentorDialog({required this.api, required this.programId});

  @override
  State<_ChangeMentorDialog> createState() => _ChangeMentorDialogState();
}

class _ChangeMentorDialogState extends State<_ChangeMentorDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _loadingMentors = true;
  List<Map<String, dynamic>> _mentors = const [];
  String? _mentorId;

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  Future<void> _loadMentors() async {
    setState(() => _loadingMentors = true);
    try {
      final json = await widget.api.get('/admin/users', query: {'role': 'mentor', 'limit': '50', 'offset': '0'});
      final items = ((json as Map<String, dynamic>)['items'] as List).cast<Map<String, dynamic>>();
      setState(() {
        _mentors = items;
        _mentorId = items.isNotEmpty ? items.first['id'] as String : null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Network Error', message: e.message);
    } finally {
      if (mounted) setState(() => _loadingMentors = false);
    }
  }

  Future<void> _save() async {
    if (_mentorId == null) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.api.post('/admin/programs/${widget.programId}/assign-mentor', body: {'mentorId': _mentorId});
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Update Failed', message: e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(32)),
        child: _loadingMentors
            ? const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()))
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Delegate Mentor', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    Text('Assign a new subject matter expert to oversee this program.', style: textTheme.bodyMedium?.copyWith(color: scheme.outline)),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      initialValue: _mentorId,
                      items: _mentors.map((u) => DropdownMenuItem(value: u['id'] as String, child: Text(u['full_name']?.toString() ?? u['email']?.toString() ?? ''))).toList(),
                      onChanged: (v) => setState(() => _mentorId = v),
                      decoration: const InputDecoration(labelText: 'Expert List', prefixIcon: Icon(Icons.admin_panel_settings_rounded)),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(child: TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(false), child: const Text('Discard'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _saving ? null : _save,
                            child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Delegate'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _CreateMilestoneDialog extends StatefulWidget {
  final ApiClient api;
  final String programId;

  const _CreateMilestoneDialog({required this.api, required this.programId});

  @override
  State<_CreateMilestoneDialog> createState() => _CreateMilestoneDialogState();
}

class _CreateMilestoneDialogState extends State<_CreateMilestoneDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _sortOrder = TextEditingController(text: '0');
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.api.post('/admin/programs/${widget.programId}/milestones', body: {
        'title': _title.text.trim(),
        'sortOrder': int.parse(_sortOrder.text.trim()),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Milestone Error', message: e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(32)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Initialize Milestone', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              Text('Create a new phase in the curriculum trail.', style: textTheme.bodyMedium?.copyWith(color: scheme.outline)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Sequence Title', prefixIcon: Icon(Icons.flag_rounded)),
                validator: (v) => (v ?? '').trim().length < 2 ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sortOrder,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Index Weight (Sort Order)', prefixIcon: Icon(Icons.reorder_rounded)),
                validator: (v) => int.tryParse((v ?? '').trim()) == null ? 'Numeric required' : null,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(false), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Initialize'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateTaskDialog extends StatefulWidget {
  final ApiClient api;
  final String programId;
  final List<Map<String, dynamic>> milestones;

  const _CreateTaskDialog({required this.api, required this.programId, required this.milestones});

  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _links = TextEditingController();
  final _deadlineLabel = TextEditingController();
  String? _milestoneId;
  DateTime? _deadlineAtLocal;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _links.dispose();
    _deadlineLabel.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final initial = _deadlineAtLocal ?? now.add(const Duration(days: 7));
    final date = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (!mounted || date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (!mounted || time == null) return;
    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      _deadlineAtLocal = combined;
      _deadlineLabel.text = '${date.year}-${date.month}-${date.day} ${time.format(context)}';
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deadlineAtLocal == null) return;
    setState(() => _saving = true);
    try {
      final resourceLinks = _links.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      await widget.api.post('/admin/programs/${widget.programId}/tasks', body: {
        'milestoneId': _milestoneId,
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'deadlineAt': _deadlineAtLocal!.toUtc().toIso8601String(),
        'resourceLinks': resourceLinks,
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Task Error', message: e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(32)),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Draft Challenge', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                Text('Define a new curriculum task for this program.', style: textTheme.bodyMedium?.copyWith(color: scheme.outline)),
                const SizedBox(height: 24),
                DropdownButtonFormField<String?>(
                  initialValue: _milestoneId,
                  items: [const DropdownMenuItem(value: null, child: Text('No Specific Milestone')), ...widget.milestones.map((m) => DropdownMenuItem(value: m['id'] as String, child: Text(m['title']?.toString() ?? '')))],
                  onChanged: (v) => setState(() => _milestoneId = v),
                  decoration: const InputDecoration(labelText: 'Associate Phase', prefixIcon: Icon(Icons.auto_awesome_mosaic_rounded)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Challenge Title', prefixIcon: Icon(Icons.assignment_rounded)),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deadlineLabel,
                  readOnly: true,
                  onTap: _pickDeadline,
                  decoration: const InputDecoration(labelText: 'Submission Threshold (Deadline)', prefixIcon: Icon(Icons.event_available_rounded)),
                  validator: (v) => _deadlineAtLocal == null ? 'Select threshold' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Objectives & Details', prefixIcon: Icon(Icons.subject_rounded)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _links,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Knowledge Bank (Links, newline separated)', prefixIcon: Icon(Icons.link_rounded)),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(false), child: const Text('Discard'))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Provision'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
