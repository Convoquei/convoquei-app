import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:convoquei_app/features/organizations/events/repositories/organization_events_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'answer_availability_provider.g.dart';

@riverpod
class AnswerAvailabilityNotifier extends _$AnswerAvailabilityNotifier {
  @override
  FutureOr<void> build() {}

  Future<OrganizationEventMembershipModel> answer({
    required String organizationId,
    required String eventId,
    required bool available,
    String? functionId,
  }) {
    return ref.read(organizationEventsRepositoryProvider).answerAvailability(
          organizationId: organizationId,
          eventId: eventId,
          available: available,
          functionId: functionId,
        );
  }

  Future<OrganizationEventMembershipModel> remove({
    required String organizationId,
    required String eventId,
  }) {
    return ref.read(organizationEventsRepositoryProvider).removeAvailability(
          organizationId: organizationId,
          eventId: eventId,
        );
  }
}




