class OrganizationFunctionMemberModel {
  final String id;
  final String memberId;
  final String memberName;
  final String memberAvatarUrl;
  final DateTime joinedAt;

  OrganizationFunctionMemberModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberAvatarUrl,
    required this.joinedAt,
  });

  factory OrganizationFunctionMemberModel.fromJson(Map<String, dynamic> json) {
    return OrganizationFunctionMemberModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      memberAvatarUrl: json['memberAvatarUrl'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String).toLocal(),
    );
  }
}
