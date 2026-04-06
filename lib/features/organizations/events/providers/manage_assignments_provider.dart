import 'package:convoquei_app/features/organizations/events/repositories/organization_events_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manage_assignments_provider.g.dart';

@riverpod
class ManageAssignments extends _$ManageAssignments {
  @override
  FutureOr<void> build() {}

  Future<void> lock({
    required String organizationId,
    required String eventId,
  }) async {
    await ref.read(organizationEventsRepositoryProvider).lockAssignments(
          organizationId: organizationId,
          eventId: eventId,
        );
  }

  Future<void> reopen({
    required String organizationId,
    required String eventId,
  }) async {
    await ref.read(organizationEventsRepositoryProvider).reopenAssignments(
          organizationId: organizationId,
          eventId: eventId,
        );
  }
}
