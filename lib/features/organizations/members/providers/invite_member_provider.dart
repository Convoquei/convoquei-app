import 'dart:async';
import 'package:convoquei_app/features/organizations/members/repositories/organization_members_repository.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_invite_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inviteOrganizationMemberProvider =
    AsyncNotifierProvider.autoDispose<
      InviteOrganizationMemberNotifier,
      OrganizationInviteModel?
    >(InviteOrganizationMemberNotifier.new);

class InviteOrganizationMemberNotifier extends AsyncNotifier<OrganizationInviteModel?> {
  @override
  FutureOr<OrganizationInviteModel?> build() => null;

  Future<OrganizationInviteModel> invite({
    required String organizationId,
    required String email,
  }) async {
    final link = ref.keepAlive(); // segura enquanto a action roda
    try {
      if (ref.mounted) {
        state = const AsyncLoading();
      }

      final repo = ref.read(organizationMembersRepositoryProvider);
      final result = await repo.inviteMemberByEmail(organizationId, email);

      if (ref.mounted) {
        state = AsyncData(result);
      }

      return result;
    } catch (e, st) {
      if (ref.mounted) {
        state = AsyncError(e, st);
      }

      Error.throwWithStackTrace(e, st);
    } finally {
      link.close();
    }
  }
}