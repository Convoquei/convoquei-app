import 'package:flutter/material.dart';

import '../../auth/controllers/login_controller.dart';
import '../../auth/controllers/user_controller.dart';
import '../../auth/models/user_model.dart';

/// Home screen — shows the logged-in user's profile.
class HomePage extends StatefulWidget {
  final AuthController authController;

  const HomePage({super.key, required this.authController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _userController = UserController();

  @override
  void initState() {
    super.initState();
    _userController.addListener(_rebuild);
  }

  @override
  void dispose() {
    _userController.removeListener(_rebuild);
    _userController.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => widget.authController.logout(),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_userController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _userController.error;
    if (error != null) {
      return Center(
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
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _userController.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final user = _userController.user;
    if (user == null) return const SizedBox.shrink();
    return _ProfileBody(user: user);
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
