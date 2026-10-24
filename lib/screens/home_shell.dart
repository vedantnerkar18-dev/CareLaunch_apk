import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/child_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_repository.dart';
import '../state/assessment_controller.dart';
import 'about_screen.dart';
import 'add_child_screen.dart';
import 'checkin_intro_screen.dart';
import 'child_zone_screen.dart';
import 'children_screen.dart';
import 'profile_screen.dart';

/// The signed-in app: four tabs along the bottom.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const int _checkInTab = 0;
  static const int _aboutTab = 2;

  int _index = _checkInTab;

  @override
  void initState() {
    super.initState();
    // A brand-new account lands on the About tab, once.
    final auth = context.read<AuthService>();
    if (auth.justRegistered.value) {
      auth.justRegistered.value = false;
      _index = _aboutTab;
    }
  }

  void _startCheckIn(ChildProfile child) {
    context
        .read<AssessmentController>()
        .startFor(child, child.ageOn(DateTime.now()));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckInIntroScreen()),
    );
  }

  /// The About tab's button: pick (or add) a child, then begin.
  Future<void> _startFromAbout() async {
    final repo = context.read<ProfileRepository>();
    final messenger = ScaffoldMessenger.of(context);

    List<ChildProfile> kids;
    try {
      kids = await repo.watchChildren().first;
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Could not load your children. Please try again.')),
      );
      return;
    }
    if (!mounted) return;

    final today = DateTime.now();
    ChildProfile? chosen;
    if (kids.isEmpty) {
      chosen = await Navigator.push<ChildProfile>(
        context,
        MaterialPageRoute(builder: (_) => const AddChildScreen()),
      );
    } else {
      final eligible = kids.where((k) => k.canScreenOn(today)).toList();
      if (eligible.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
              content: Text('Check-ins are designed for children aged 5 to 14.')),
        );
        return;
      }
      if (eligible.length == 1) {
        chosen = eligible.first;
      } else {
        chosen = await showModalBottomSheet<ChildProfile>(
          context: context,
          builder: (_) => _ChildPicker(children: eligible, today: today),
        );
      }
    }
    if (chosen != null && mounted) _startCheckIn(chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps every tab alive, so nothing reloads when you switch.
      body: IndexedStack(
        index: _index,
        children: [
          ChildrenScreen(
            onStartCheckIn: _startCheckIn,
            onLearnMore: () => setState(() => _index = _aboutTab),
          ),
          const ChildZoneScreen(),
          AboutScreen(ctaLabel: 'Start a check-in', onCta: _startFromAbout),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Check-in',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: 'Child Zone',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'About',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for choosing which child a check-in is for.
class _ChildPicker extends StatelessWidget {
  final List<ChildProfile> children;
  final DateTime today;
  const _ChildPicker({required this.children, required this.today});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Who is this check-in for?',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          for (final c in children)
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.child_care)),
              title: Text(c.name),
              subtitle: Text('Age ${c.ageOn(today)}'),
              onTap: () => Navigator.pop(context, c),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}