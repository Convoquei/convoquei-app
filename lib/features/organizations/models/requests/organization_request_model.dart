import 'package:convoquei_app/core/models/base_paged_request.dart';

class OrganizationRequestModel extends BasePagedRequest {
  final String? name;

  OrganizationRequestModel({
    required super.page,
    required super.size,
    this.name,
  });

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (name != null) {
      data['name'] = name;
    }
    return data;
  }
}
