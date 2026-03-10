import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:convoquei_app/features/organizations/events/repositories/organization_events_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'answer_availability_provider.g.dart';

/// Estado de uma chamada de resposta de disponibilidade.
class AnswerAvailabilityState {
  final bool isLoading;
  final Object? error;
  final OrganizationEventMembershipModel? result;

  const AnswerAvailabilityState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  AnswerAvailabilityState copyWith({
    bool? isLoading,
    Object? error,
    OrganizationEventMembershipModel? result,
    bool clearError = false,
  }) {
    return AnswerAvailabilityState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      result: result ?? this.result,
    );
  }
}

@riverpod
class AnswerAvailabilityNotifier extends _$AnswerAvailabilityNotifier {
  @override
  AnswerAvailabilityState build() {
    ref.keepAlive();
    return const AnswerAvailabilityState();
  }

  Future<OrganizationEventMembershipModel?> answer({
    required String organizationId,
    required String eventId,
    required bool available,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await ref
          .read(organizationEventsRepositoryProvider)
          .answerAvailability(organizationId: organizationId, eventId: eventId, available: available);

      if (!ref.mounted) return null;

      state = state.copyWith(isLoading: false, result: result);
      return result;
    } catch (e) {
      if (!ref.mounted) return null;

      state = state.copyWith(isLoading: false, error: e);
      return null;
    }
  }

  Future<OrganizationEventMembershipModel?> remove({
    required String organizationId,
    required String eventId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await ref
          .read(organizationEventsRepositoryProvider)
          .removeAvailability(organizationId: organizationId, eventId: eventId);

      if (!ref.mounted) return null;

      state = state.copyWith(isLoading: false, result: result);
      return result;
    } catch (e) {
      if (!ref.mounted) return null;

      state = state.copyWith(isLoading: false, error: e);
      return null;
    }
  }
}




