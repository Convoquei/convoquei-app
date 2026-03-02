import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/models/auth_state.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/home/pages/home_page.dart';

/// Listens to [AuthController] and routes to the correct screen.
///
/// The native splash is kept visible (via [FlutterNativeSplash.preserve])
/// while auth is still initialising, then removed once the state is known.
///
/// - Loading / unknown  → native splash stays on screen
/// - Authenticated      → [HomePage]
/// - Unauthenticated    → [LoginPage]
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final state = auth.state;

    if (auth.isInitializing || state.status == AuthStatus.unknown) {
      // Still loading – keep the native splash visible (do nothing).
      return const Scaffold(
        body: SizedBox.shrink(),
      );
    }

    // Auth state resolved – dismiss the native splash.
    FlutterNativeSplash.remove();

    return switch (state.status) {
      AuthStatus.authenticated => const HomePage(),
      _ => const LoginPage(),
    };
  }
}
