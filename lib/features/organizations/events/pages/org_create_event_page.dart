import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/create_organization_event_request.dart';
import 'package:convoquei_app/features/organizations/events/pages/org_event_form_page.dart';
import 'package:convoquei_app/features/organizations/events/providers/create_event_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_all_events_membership_provider.dart';
import 'package:convoquei_app/features/organizations/events/models/events_filter_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrgCreateEventPage extends ConsumerWidget {
  final String organizationId;

  const OrgCreateEventPage({super.key, required this.organizationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OrgEventFormPage(
      organizationId: organizationId,
      finishLabel: 'Criar Evento',
      onSave: ({required step1, required step2, required step3}) async {
        final request = CreateOrganizationEventRequest.fromSteps(
          name: step1.name,
          description: step1.description,
          location: step1.location,
          startDate: step1.startAt!,
          endDate: step1.endAt!,
          step2: step2,
          step3: step3,
        );

        try {
          await ref.read(createEventProvider.notifier).create(
                organizationId: organizationId,
                request: request,
              );

          if (!context.mounted) return false;

          ref.read(eventMembershipProvider.notifier).reset(
                organizationId,
                const EventsFilter(),
              );

          ToastFeedbackService.showToast(
            context,
            'Evento criado com sucesso!',
            ToastType.success,
          );

          return true;
        } on ApiException catch (e) {
          if (!context.mounted) return false;

          ToastFeedbackService.showToast(
            context,
            e.userMessage,
            ToastType.error,
          );

          return false;
        }
      },
    );
  }
}
