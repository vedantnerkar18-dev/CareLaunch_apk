import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/child_profile.dart';
import '../services/profile_repository.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  static const _genders = ['Girl', 'Boy', 'Prefer not to say'];

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _language = TextEditingController();
  DateTime? _dob;
  String? _gender;
  String? _dobError;
  String? _saveError;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _language.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    // Only dates that make the child 5 to 14 years old today.
    final first = DateTime(now.year - 15, now.month, now.day + 1);
    final last = DateTime(now.year - 5, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? last,
      firstDate: first,
      lastDate: last,
      helpText: 'Child\'s date of birth',
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobError = null;
      });
    }
  }

  Future<void> _save() async {
    final valid = _formKey.currentState!.validate();
    if (_dob == null) setState(() => _dobError = 'Choose a date of birth');
    if (!valid || _dob == null) return;

    final repo = context.read<ProfileRepository>();
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _saveError = null;
    });
    try {
      final draft = ChildProfile(
        id: '',
        name: _name.text,
        dob: _dob!,
        gender: _gender,
        language: _language.text,
      );
      final id = await repo.addChild(draft);
      navigator.pop(draft.withId(id));
    } catch (_) {
      if (mounted) {
        setState(() => _saveError =
            'Could not save. Please check your connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add a child')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'First name or nickname',
                      helperText: 'A first name is enough. No surname needed.',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.name,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickDob,
                    icon: const Icon(Icons.cake_outlined),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(_dob == null
                          ? 'Date of birth'
                          : formatDate(_dob!)),
                    ),
                  ),
                  if (_dobError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 12),
                      child: Text(_dobError!,
                          style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'CareLaunch is designed for children aged 5 to 14.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  Text('Gender (optional)', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final g in _genders)
                        ChoiceChip(
                          label: Text(g),
                          selected: _gender == g,
                          onSelected: (on) =>
                              setState(() => _gender = on ? g : null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _language,
                    decoration: const InputDecoration(
                      labelText: 'Language spoken at home (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_saveError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_saveError!,
                          style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}