import 'package:convoquei_app/features/organizations/events/repositories/organization_events_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manage_participant_provider.g.dart';

@riverpod
class ManageParticipant extends _$ManageParticipant {
  @override
  FutureOr<void> build() {}

  Future<void> assign({
    required String organizationId,
    required String eventId,
    required String membershipId,
  }) async {
    await ref.read(organizationEventsRepositoryProvider).assignParticipant(
          organizationId: organizationId,
          eventId: eventId,
          membershipId: membershipId,
        );
  }

  Future<void> reject({
    required String organizationId,
    required String eventId,
    required String membershipId,
  }) async {
    await ref.read(organizationEventsRepositoryProvider).rejectParticipant(
          organizationId: organizationId,
          eventId: eventId,
          membershipId: membershipId,
        );
  }

  Future<void> removeAssigned({
    required String organizationId,
    required String eventId,
    required String membershipId,
  }) async {
    await ref
        .read(organizationEventsRepositoryProvider)
        .removeAssignedParticipant(
          organizationId: organizationId,
          eventId: eventId,
          membershipId: membershipId,
        );
  }

  Future<void> removeOwn({
    required String organizationId,
    required String eventId,
  }) async {
    await ref.read(organizationEventsRepositoryProvider).removeAvailability(
          organizationId: organizationId,
          eventId: eventId,
        );
  }

  Future<void> notifyParticipants({
    required String organizationId,
    required String eventId,
  }) async {
    await ref
        .read(organizationEventsRepositoryProvider)
        .notifyEventParticipants(
          organizationId: organizationId,
          eventId: eventId,
        );
  }
}
