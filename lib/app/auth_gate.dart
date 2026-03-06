import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/models/auth_state.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/home/pages/home_page.dart';

/// Listens to [authProvider] and routes to the correct screen.
///
/// The native splash is kept visible (via [FlutterNativeSplash.preserve])
/// while auth is still initialising, then removed once the state is known.
///
/// - Loading / unknown  → native splash stays on screen
/// - Authenticated      → [HomePage]
/// - Unauthenticated    → [LoginPage]
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      debugPrint('Auth state changed: ${previous?.status} → ${next.status}');

      if (previous?.status == AuthStatus.authenticated &&
          next.status == AuthStatus.unauthenticated) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    if (authState.status == AuthStatus.unknown) {
      return const Scaffold(
        body: SizedBox.shrink(),
      );
    }

    // Auth state resolved – dismiss the native splash.
    FlutterNativeSplash.remove();

    return switch (authState.status) {
      AuthStatus.authenticated => const HomePage(),
      _ => const LoginPage(),
    };
  }
}
