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

