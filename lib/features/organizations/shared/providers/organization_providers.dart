import 'package:convoquei_app/features/organizations/shared/models/organization_invite_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_my_member_profile_model.dart';
import 'package:convoquei_app/features/organizations/home/models/requests/find_invites_user_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../models/organization_model.dart';
import '../../home/models/requests/list_organizations_request.dart';
import '../repositories/organization_repository.dart';

// -- Repository provider -----------------------------------------------------
final organizationRepositoryProvider = Provider<OrganizationRepository>(
  (ref) => OrganizationRepository(apiClient: ref.watch(apiClientProvider)),
);
// -- Data providers ----------------------------------------------------------
final userOrganizationsProvider = FutureProvider<List<OrganizationModel>>((
  ref,
) async {
  final repo = ref.watch(organizationRepositoryProvider);
  final response = await repo.findAll(
    ListOrganizationRequest(page: 0, size: 20),
  );
  return response.items;
});

/// Fetches the current user membership for a given organization.
/// - Returns [OrganizationMyMemberProfile] on success.
/// - Propagates [ForbiddenException] when the user is no longer a member (403).
final currentOrgMemberProvider =
    FutureProvider.family<OrganizationMyMemberProfile, String>((
      ref,
      organizationId,
    ) async {
      final repo = ref.watch(organizationRepositoryProvider);
      return repo.findMe(organizationId);
    });
// -- Actions -----------------------------------------------------------------
final createOrganizationProvider =
    Provider<Future<OrganizationModel> Function(String name, String type)>((
      ref,
    ) {
      final repo = ref.watch(organizationRepositoryProvider);
      return (name, type) => repo.create(name: name, type: type);
    });
final findAllInvitesByUserProvider =
    FutureProvider<List<OrganizationInviteModel>>((ref) async {
      final repo = ref.watch(organizationRepositoryProvider);
      final response = await repo.findAllInvitesByUser(
        FindInvitesUserRequest(page: 0, size: 20),
      );
      return response.items;
    });
final responseInviteProvider =
    Provider<Future<void> Function(String inviteId, bool accept)>((ref) {
      final repo = ref.watch(organizationRepositoryProvider);
      return (inviteId, accept) =>
          accept ? repo.acceptInvite(inviteId) : repo.declineInvite(inviteId);
    });
