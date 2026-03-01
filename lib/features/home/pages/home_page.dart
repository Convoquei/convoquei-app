import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/controllers/login_controller.dart';
import '../../auth/controllers/user_controller.dart';
import '../../auth/models/user_model.dart';

/// Home screen — shows the logged-in user's profile.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                'Erro ao carregar perfil',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(userControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (user) => _ProfileBody(user: user),
      ),
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
              backgroundImage: (user.avatarUrl != null &&
                      user.avatarUrl!.isNotEmpty)
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                  ? Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
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
                  color:
                      user.isEmailVerified ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
