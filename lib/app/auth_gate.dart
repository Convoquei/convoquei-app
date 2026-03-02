import 'package:flutter/material.dart';

import '../../features/auth/controllers/login_controller.dart';
import '../../features/auth/models/auth_state.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/home/pages/home_page.dart';

/// Listens to [AuthController] and routes to the correct screen.
///
/// - Loading / unknown  → splash indicator
/// - Authenticated      → [HomePage]
/// - Unauthenticated    → [LoginPage]
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authController = AuthController();

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authController,
      builder: (context, _) {
        final state = _authController.state;

        if (_authController.isInitializing || state.status == AuthStatus.unknown) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return switch (state.status) {
          AuthStatus.authenticated => HomePage(authController: _authController),
          _ => LoginPage(authController: _authController),
        };
      },
    );
  }
}
