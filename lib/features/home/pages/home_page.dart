import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_model.dart';
import '../controllers/user_organization_controller.dart';
import '../widgets/perfil_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthController, UserModel>(
          (auth) => auth.state.user!,
    );

    final controller = context.read<UserOrganizationController>();

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: PerfilHeader(
              user: user,
              onNotificationTap: () {},
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: controller.fetchOrganizations(),
              builder: (context, snapshot) {
                // 🔄 Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // ❌ Erro
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      controller.buildErrorFetchAPI(snapshot.error),
                    ),
                  );
                }

                // ✅ Sucesso
                final organizations = controller.organizations;

                if (organizations.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma organização encontrada.'),
                  );
                }

                return ListView.builder(
                  itemCount: organizations.length,
                  itemBuilder: (context, index) {
                    final org = organizations[index];
                    return ListTile(
                      title: Text(org.name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}