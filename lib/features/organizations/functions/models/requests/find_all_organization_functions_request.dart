import 'package:convoquei_app/core/models/base_paged_request.dart';

class FindAllOrganizationFunctionsRequest extends BasePagedRequest {
  final String? name;

  FindAllOrganizationFunctionsRequest({
    required super.page,
    required super.size,
    this.name,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (name != null && name!.isNotEmpty) {
      json['name'] = name;
    }
    return json;
  }
}
