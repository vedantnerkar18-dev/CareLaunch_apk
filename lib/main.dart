import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/profile_repository.dart';
import 'state/assessment_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CareLaunchApp());
}

class CareLaunchApp extends StatelessWidget {
  const CareLaunchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AssessmentController()),
        Provider(create: (_) => AuthService(FirebaseAuth.instance)),
        Provider(
          create: (_) => ProfileRepository(
            FirebaseFirestore.instance,
            () => FirebaseAuth.instance.currentUser!.uid,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'CareLaunch',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}

/// Signed out: login screen. Signed in: the caregiver's children.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return ValueListenableBuilder<bool>(
      valueListenable: auth.registering,
      builder: (context, registering, _) => StreamBuilder<User?>(
        stream: auth.authStateChanges,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.data == null || registering) return const LoginScreen();
          return const HomeShell();
        },
      ),
    );
  }
}