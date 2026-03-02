import 'package:flutter/material.dart';

import '../../auth/controllers/login_controller.dart';
import '../../auth/models/user_model.dart';

/// Home screen — shows the logged-in user's profile.
class HomePage extends StatelessWidget {
  final AuthController authController;

  const HomePage({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    // user is guaranteed non-null when AuthStatus.authenticated
    final user = authController.state.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: _ProfileBody(user: user),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final UserModel user;

  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundImage:
                  (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 36),
                    )
                  : null,
            ),
            const SizedBox(height: 20),
            Text(user.name, style: tt.titleLarge),
            const SizedBox(height: 4),
            Text(user.email, style: tt.bodyMedium),
            const SizedBox(height: 12),
            // E-mail verified badge
            Chip(
              avatar: Icon(
                user.isEmailVerified
                    ? Icons.verified_outlined
                    : Icons.mark_email_unread_outlined,
                size: 16,
                color: user.isEmailVerified ? Colors.green : Colors.orange,
              ),
              label: Text(
                user.isEmailVerified
                    ? 'E-mail verificado'
                    : 'E-mail não verificado',
                style: TextStyle(
                  color: user.isEmailVerified ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
