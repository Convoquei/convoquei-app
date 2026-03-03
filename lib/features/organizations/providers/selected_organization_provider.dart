import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/organization_model.dart';

/// Holds the currently "entered" organization.
/// Null means the user is not inside any organization.
class SelectedOrganizationNotifier extends Notifier<OrganizationModel?> {
  @override
  OrganizationModel? build() => null;

  void select(OrganizationModel org) => state = org;
  void clear() => state = null;
}

final selectedOrganizationProvider =
    NotifierProvider<SelectedOrganizationNotifier, OrganizationModel?>(
  SelectedOrganizationNotifier.new,
);
