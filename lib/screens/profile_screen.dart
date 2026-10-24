import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/caregiver_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_repository.dart';
import '../state/assessment_controller.dart';

/// The "Profile" tab: who is signed in, and sign out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final repo = context.read<ProfileRepository>();
    final theme = Theme.of(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: StreamBuilder<CaregiverProfile?>(
              stream: repo.watchCaregiver(),
              builder: (context, snap) {
                // Falls back to the sign-in details if the profile is not saved.
                final p = snap.data;
                final name = (p?.name.isNotEmpty ?? false)
                    ? p!.name
                    : (user?.displayName ?? '');
                final email = (p?.email.isNotEmpty ?? false)
                    ? p!.email
                    : (user?.email ?? '');
                final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        child: Text(initial,
                            style: theme.textTheme.headlineMedium),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name.isEmpty ? 'Your profile' : name,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(email,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 20),
                    Card(
                      child: Column(
                        children: [
                          if (p != null)
                            ListTile(
                              leading: const Icon(Icons.family_restroom_outlined),
                              title: const Text('Relationship to the child'),
                              subtitle: Text(p.relationship.label),
                            ),
                          if ((p?.phone ?? '').isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.phone_outlined),
                              title: const Text('Mobile number'),
                              subtitle: Text(p!.phone!),
                            ),
                          const ListTile(
                            leading: Icon(Icons.verified_user_outlined),
                            title: Text('Consent'),
                            subtitle: Text(
                              'You agreed to CareLaunch storing your '
                              'details and your children\'s check-in '
                              'results when you registered.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<AssessmentController>().reset();
                        auth.signOut();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Sign out'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}