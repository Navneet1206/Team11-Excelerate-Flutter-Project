import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class AdminUsersScreen extends StatefulWidget {
  final ApiClient api;

  const AdminUsersScreen({super.key, required this.api});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  static const _pageSize = 20;

  String? _role;

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
      if (_role != null) query['role'] = _role!;

      final json = await widget.api.get('/admin/users', query: query);
      final items = ((json as Map<String, dynamic>)['items'] as List).cast<Map<String, dynamic>>();

      setState(() {
        if (reset) _items.clear();
        _items.addAll(items);
        _offset = nextOffset + items.length;
        _hasMore = items.length == _pageSize;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Failed to load users', message: e.message);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _openCreateUser() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => _CreateUserDialog(api: widget.api),
    );

    if (created == true) {
      if (!mounted) return;
      showAppSnack(context, 'User created');
      _load(reset: true);
    }
  }

  void _setRole(String? role) {
    setState(() => _role = role);
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
          'User Management',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filledTonal(
              onPressed: _openCreateUser,
              icon: const Icon(Icons.person_add_rounded, size: 20),
            ),
          ),
        ],
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
                _FilterChip(label: 'All Users', selected: _role == null, onTap: () => _setRole(null)),
                const SizedBox(width: 8),
                _FilterChip(label: 'Learners', selected: _role == 'learner', onTap: () => _setRole('learner')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Mentors', selected: _role == 'mentor', onTap: () => _setRole('mentor')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Admins', selected: _role == 'admin', onTap: () => _setRole('admin')),
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
                        ? _EmptyUsers()
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

                              final u = _items[i];
                              final role = u['role']?.toString() ?? 'learner';
                              final name = u['full_name']?.toString() ?? 'User';
                              final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                              final roleColor = switch (role) {
                                'admin' => Colors.deepPurple,
                                'mentor' => scheme.secondary,
                                'learner' => scheme.primary,
                                _ => scheme.outline,
                              };

                              return Container(
                                decoration: BoxDecoration(
                                  color: scheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: scheme.outlineVariant),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: roleColor.withValues(alpha: 0.1),
                                    child: Text(initial, style: TextStyle(color: roleColor, fontWeight: FontWeight.bold)),
                                  ),
                                  title: Text(name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                  subtitle: Text(u['email']?.toString() ?? '', style: textTheme.bodySmall),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: roleColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      role.toUpperCase(),
                                      style: TextStyle(color: roleColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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

class _EmptyUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 64, color: scheme.outline),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CreateUserDialog extends StatefulWidget {
  final ApiClient api;

  const _CreateUserDialog({required this.api});

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController(text: 'Password123!');
  final _fullName = TextEditingController();
  String _role = 'learner';
  bool _saving = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _fullName.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await widget.api.post('/admin/users', body: {
        'email': _email.text.trim(),
        'password': _password.text,
        'role': _role,
        'fullName': _fullName.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Create user failed', message: e.message);
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Provision User',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure credentials for a new system user.',
                style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: 'Full Display Name', prefixIcon: Icon(Icons.badge_rounded)),
                validator: (v) => (v ?? '').trim().length < 2 ? 'Enter a valid name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_rounded)),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Email required';
                  if (!value.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _role,
                items: const [
                  DropdownMenuItem(value: 'learner', child: Text('Learner')),
                  DropdownMenuItem(value: 'mentor', child: Text('Mentor')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'learner'),
                decoration: const InputDecoration(labelText: 'Access Level', prefixIcon: Icon(Icons.assignment_ind_rounded)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Initial Password', prefixIcon: Icon(Icons.lock_rounded)),
                validator: (v) => (v ?? '').length < 6 ? 'Min 6 chars' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text('Initialize Account'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
