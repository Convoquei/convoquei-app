import 'package:convoquei_app/core/models/base_paged_request.dart';

class FindAllOrganizationMembersRequest extends BasePagedRequest {
  String? name;
  String? status = "ACTIVE";
  String? roleId;

  FindAllOrganizationMembersRequest({
    required super.page,
    required super.size,
    this.name,
    this.status,
    this.roleId,
  });

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (name != null) data['name'] = name;
    if (status != null) data['status'] = status;
    if (roleId != null) data['roleId'] = roleId;
    return data;
  }
}
