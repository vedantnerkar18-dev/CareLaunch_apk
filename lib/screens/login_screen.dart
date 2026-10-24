import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/caregiver_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_repository.dart';
import '../utils/validators.dart';
import 'about_screen.dart';

/// Sign in, or create a caregiver account (with consent).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _isRegister = false;
  bool _consent = false;
  bool _busy = false;
  bool _hidePassword = true;
  Relationship _relationship = Relationship.mother;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isRegister && !_consent) {
      setState(() => _error = 'Please tick the consent box to create an account.');
      return;
    }

    final auth = context.read<AuthService>();
    final repo = context.read<ProfileRepository>();
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      if (_isRegister) {
        auth.registering.value = true;
        await auth.register(
          email: _email.text,
          password: _password.text,
          displayName: _name.text,
        );
        try {
          await repo.saveCaregiver(CaregiverProfile(
            name: _name.text,
            relationship: _relationship,
            email: _email.text,
            phone: _phone.text,
          ));
        } catch (_) {
          // No account without a saved consent record. Undo, so they can retry.
          await auth.deleteCurrentUser();
          rethrow;
        }
        auth.justRegistered.value = true;
      } else {
        await auth.signIn(email: _email.text, password: _password.text);
      }
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyMessage(e));
    } finally {
      auth.registering.value = false;
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openAbout() async {
    final create = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AboutScreen(ctaLabel: 'Create my account'),
      ),
    );
    if (create == true && mounted) {
      setState(() {
        _isRegister = true;
        _error = null;
      });
    }
  }

  Future<void> _forgotPassword() async {
    if (Validators.email(_email.text) != null) {
      setState(() => _error = 'Enter your email above, then tap "Forgot password?".');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AuthService>().sendPasswordReset(_email.text);
    } catch (_) {
      // Same message either way, so nobody can use this to check who has an account.
    }
    messenger.showSnackBar(const SnackBar(
      content: Text('If an account exists for that email, a reset link is on its way.'),
    ));
  }

  void _showPrivacyNote() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('What CareLaunch stores'),
        content: const SingleChildScrollView(
          child: Text(
            'About you: your name, how you are related to the child, your '
            'email, and your phone number if you add it.\n\n'
            'About each child: first name or nickname, date of birth, and '
            'optionally gender and home language.\n\n'
            'About each check-in: the date and the result levels. The '
            'individual answers are not saved.\n\n'
            'Only your account can open this information. You can remove a '
            'child and all of their check-ins at any time from the "My '
            'children" screen.\n\n'
            'CareLaunch is a screening and awareness tool. It does not '
            'diagnose any condition.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 16),
                  Icon(Icons.rocket_launch,
                      size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  Text('CareLaunch',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    _isRegister
                        ? 'Create your caregiver account'
                        : 'Welcome back',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  if (_isRegister) ...[
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          labelText: 'Your name', border: OutlineInputBorder()),
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Relationship>(
                      initialValue: _relationship,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Your relationship to the child',
                          border: OutlineInputBorder()),
                      items: [
                        for (final r in Relationship.values)
                          DropdownMenuItem(value: r, child: Text(r.label)),
                      ],
                      onChanged: (v) =>
                          setState(() => _relationship = v ?? _relationship),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                    validator: Validators.email,
                  ),
                  if (_isRegister) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'Mobile number (optional)',
                          border: OutlineInputBorder()),
                      validator: Validators.phoneOptional,
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: _hidePassword,
                    autofillHints: _isRegister
                        ? const [AutofillHints.newPassword]
                        : const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                    validator: _isRegister
                        ? Validators.password
                        : (v) => (v ?? '').isEmpty ? 'Enter your password' : null,
                  ),
                  if (_isRegister) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirm,
                      obscureText: _hidePassword,
                      decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          border: OutlineInputBorder()),
                      validator: (v) =>
                          v != _password.text ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: _consent,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (v) => setState(() => _consent = v ?? false),
                      title: const Text(
                        'I am the child\'s parent or legal guardian (or '
                        'authorised by them), and I agree to CareLaunch '
                        'storing the details I enter.',
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _showPrivacyNote,
                        child: const Text('What does CareLaunch store?'),
                      ),
                    ),
                  ],
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(_error!,
                          style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isRegister ? 'Create account' : 'Sign in'),
                    ),
                  ),
                  if (!_isRegister)
                    TextButton(
                      onPressed: _busy ? null : _forgotPassword,
                      child: const Text('Forgot password?'),
                    ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _isRegister = !_isRegister;
                              _error = null;
                            }),
                    child: Text(_isRegister
                        ? 'I already have an account'
                        : 'New here? Create an account'),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _openAbout,
                    child: const Text('What is CareLaunch?'),
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