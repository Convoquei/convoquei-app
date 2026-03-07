class OrganizationMemberFunctionModel {
  final String id;
  final String name;

  const OrganizationMemberFunctionModel({
    required this.id,
    required this.name,
  });

  factory OrganizationMemberFunctionModel.fromJson(Map<String, dynamic> json) {
    return OrganizationMemberFunctionModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
