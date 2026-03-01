import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/controllers/login_controller.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/home/pages/home_page.dart';

/// Listens to [authControllerProvider] and routes to the correct screen.
///
/// - Loading / unknown  → splash indicator
/// - Authenticated      → [HomePage]
/// - Unauthenticated    → [LoginPage]
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authControllerProvider);

    return authAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const LoginPage(),
      data: (state) => switch (state.status) {
        AuthStatus.authenticated => const HomePage(),
        _ => const LoginPage(),
      },
    );
  }
}

