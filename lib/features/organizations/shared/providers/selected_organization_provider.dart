import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
