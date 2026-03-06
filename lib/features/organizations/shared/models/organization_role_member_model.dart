class OrganizationRoleMemberModel {
  final String id;
  final String name;
  final String avatarUrl;

  OrganizationRoleMemberModel({
    required this.id,
    required this.name,
    required this.avatarUrl
  });

  factory OrganizationRoleMemberModel.fromJson(Map<String, dynamic> json) {
    return OrganizationRoleMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
    );
  }
}