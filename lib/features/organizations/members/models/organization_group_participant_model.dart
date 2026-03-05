class OrganizationGroupParticipantModel {
  final String id;
  final String memberId;
  final String memberName;
  final String memberAvatarUrl;
  final DateTime joinedAt;

  OrganizationGroupParticipantModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberAvatarUrl,
    required this.joinedAt,
  });

  factory OrganizationGroupParticipantModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrganizationGroupParticipantModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      memberAvatarUrl: json['memberAvatarUrl'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}
