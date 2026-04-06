import 'package:convoquei_app/features/organizations/events/repositories/organization_events_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cancel_event_provider.g.dart';

@riverpod
class CancelEventNotifier extends _$CancelEventNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> cancel({
    required String organizationId,
    required String eventId,
  }) async {
    await ref.read(organizationEventsRepositoryProvider).cancelEvent(
          organizationId: organizationId,
          eventId: eventId,
        );
  }
}
