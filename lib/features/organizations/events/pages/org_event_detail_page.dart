import 'package:convoquei_app/core/widgets/app_loading_info.dart';
import 'package:convoquei_app/core/widgets/app_loading_screen.dart';
import 'package:convoquei_app/core/widgets/error_retry_state.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_event_details_by_id_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrgEventDetailPage extends ConsumerWidget {
  final String organizationId;
  final String eventId;

  const OrgEventDetailPage({
    super.key,
    required this.organizationId,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(
      findEventDetailsByIdProvider(
        organizationId: organizationId,
        eventId: eventId,
      ),
    );

    return Scaffold(
      body: detailsAsync.when(
        loading: () => const AppLoadingScreen(
          content: AppLoadingInfo(
            label: 'Carregando evento...',
            description: 'Buscando detalhes e participantes',
          ),
          skeleton: AppLoadingSkeleton.details,
        ),
        error: (_, __) => Center(
          child: ErrorRetryState(
            message: 'Não foi possível carregar o evento',
            description: 'Verifique sua conexão e tente novamente.',
            onRetry: () => ref.invalidate(
              findEventDetailsByIdProvider(
                organizationId: organizationId,
                eventId: eventId,
              ),
            ),
          ),
        ),
        data: (details) => _EventDetailContent(
          organizationId: organizationId,
          eventId: eventId,
          details: details,
        ),
      ),
    );
  }
}

class _EventDetailContent extends ConsumerWidget {
  final String organizationId;
  final String eventId;
  final OrganizationEventDetailsModel details;

  const _EventDetailContent({
    required this.organizationId,
    required this.eventId,
    required this.details,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(
        findEventDetailsByIdProvider(
          organizationId: organizationId,
          eventId: eventId,
        ).future,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                details.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
