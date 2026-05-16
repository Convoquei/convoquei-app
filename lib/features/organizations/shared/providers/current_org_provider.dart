import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider não-nullable da org atual, válido apenas dentro do OrganizationShell.
/// Injetado via ProviderScope.overrides — nunca expõe null às branches.
final currentOrgProvider = Provider<OrganizationModel>(
  (ref) => throw StateError('currentOrgProvider precisa ser sobrescrito pelo OrganizationShell.'),
  name: 'currentOrgProvider',
);
