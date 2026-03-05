class OrganizationMemberGroupModel {
  final String id;
  final String name;

  const OrganizationMemberGroupModel({
    required this.id,
    required this.name,
  });

  factory OrganizationMemberGroupModel.fromJson(Map<String, dynamic> json) {
    return OrganizationMemberGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
