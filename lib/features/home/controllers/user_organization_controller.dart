import 'package:convoquei_app/core/loading_controller.dart';
import 'package:convoquei_app/features/organizations/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/models/requests/organization_request_model.dart';
import 'package:convoquei_app/features/organizations/repository/organization_repository.dart';

class UserOrganizationController extends LoadingController {
  final OrganizationRepository _organizationRepository;

  List<OrganizationModel> _organizations = [];
  List<OrganizationModel> get organizations => _organizations;

  UserOrganizationController({
    required OrganizationRepository organizationRepository,
  }) : _organizationRepository = organizationRepository;

  Future<void> fetchOrganizations() async {
    await run(() async {
      final response = await _organizationRepository.findAll(
        OrganizationRequestModel(page: 1, size: 20),
      );
      _organizations = response.items;
    });
  }
}