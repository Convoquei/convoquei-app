import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/features/organizations/models/organization_invite_model.dart';
import 'package:convoquei_app/features/organizations/models/requests/find_invites_user_request_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../models/organization_model.dart';
import '../models/requests/organization_request_model.dart';
import '../repository/organization_repository.dart';

// ── Repository provider ─────────────────────────────────────────────────────

final organizationRepositoryProvider = Provider<OrganizationRepository>(
  (ref) => OrganizationRepository(
    apiClient: ref.watch(apiClientProvider),
  ),
);

// ── Data provider ───────────────────────────────────────────────────────────

final userOrganizationsProvider = FutureProvider<List<OrganizationModel>>(
  (ref) async {
    final repo = ref.watch(organizationRepositoryProvider);
    final response = await repo.findAll(
      OrganizationRequestModel(page: 0, size: 20),
    );
    return response.items;
  },
);

// ── Actions ─────────────────────────────────────────────────────────────────

final createOrganizationProvider = Provider<Future<OrganizationModel> Function(String name, String type)>(
  (ref) {
    final repo = ref.watch(organizationRepositoryProvider);
    return (name, type) => repo.create(name: name, type: type);
  },
);

final findAllInvitesByUserProvider = FutureProvider<List<OrganizationInviteModel>>(
  (ref) async {
    final repo = ref.watch(organizationRepositoryProvider);
    final response = await repo.findAllInvitesByUser(
      FindInvitesUserRequestModel(page: 0, size: 20),
    );

    return response.items;
  },
);

final responseInviteProvider = Provider<Future<void> Function(String inviteId, bool accept)>(
  (ref) {
    final repo = ref.watch(organizationRepositoryProvider);

    return (inviteId, accept) => accept
        ? repo.acceptInvite(inviteId)
        : repo.declineInvite(inviteId);
  },
);