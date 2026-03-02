import 'package:convoquei_app/features/home/widgets/create_organization_card.dart';
import 'package:convoquei_app/features/home/widgets/home_empty_state.dart';
import 'package:convoquei_app/features/home/widgets/home_section.dart';
import 'package:convoquei_app/features/home/widgets/organization_home_card.dart';
import 'package:convoquei_app/features/organizations/models/organization_model.dart';
import 'package:convoquei_app/features/home/widgets/create_organization_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../organizations/providers/organization_providers.dart';
import '../widgets/perfil_header.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user!;
    final AsyncValue<List<OrganizationModel>> organizationsAsync = ref.watch(
      userOrganizationsProvider,
    );

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: PerfilHeader(user: user, onNotificationTap: () {}),
          ),

          if (organizationsAsync.maybeWhen(
            data: (list) => list.isEmpty,
            orElse: () => false,
          ))
            Expanded(
              child: HomeEmptyState(
                onJoinWithCode: () {},
                onCreateOrganization: () =>
                    CreateOrganizationModal.show(context),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    organizationsAsync.when(
                      loading: () => HomeSection(
                        title: "Organizações",
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 12,
                          bottom: 4,
                        ),
                        children: [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ],
                      ),
                      error: (error, _) => HomeSection(
                        title: "Organizações",
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 12,
                          bottom: 4,
                        ),
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  error.toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: () =>
                                      ref.invalidate(userOrganizationsProvider),
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      data: (organizations) {
                        return HomeSection(
                          title: "Organizações",
                          trailing: Text("${organizations.length}"),
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 12,
                            bottom: 4,
                          ),
                          children: [
                            SizedBox(
                              height: 180,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                itemCount: organizations.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final org = organizations[index];
                                  const role = 'Membro';
                                  const isAdmin = true;
                                  return OrganizationHomeCard(
                                    organization: org,
                                    role: role,
                                    isAdmin: isAdmin,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            CreateOrganizationCardDashed(
                              onTap: () =>
                                  CreateOrganizationModal.show(context),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
