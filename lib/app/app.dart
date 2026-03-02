import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/repository/auth_repository.dart';
import '../features/auth/repository/user_repository.dart';
import '../features/home/controllers/user_organization_controller.dart';
import '../features/organizations/repository/organization_repository.dart';
import 'auth_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => TokenStorage()),
        Provider(
          create: (context) => ApiClient(
            tokenStorage: context.read<TokenStorage>(),
            baseUrl: AppConstants.baseUrl,
          ),
        ),
        Provider(
          create: (context) => AuthRepository(
            apiClient: context.read<ApiClient>(),
            tokenStorage: context.read<TokenStorage>(),
          ),
        ),
        Provider(
          create: (context) => UserRepository(
            apiClient: context.read<ApiClient>(),
          ),
        ),
        Provider(
          create: (context) => OrganizationRepository(
            apiClient: context.read<ApiClient>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthController(
            authRepository: context.read<AuthRepository>(),
            userRepository: context.read<UserRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserOrganizationController(
            organizationRepository: context.read<OrganizationRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Convoquei',
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}