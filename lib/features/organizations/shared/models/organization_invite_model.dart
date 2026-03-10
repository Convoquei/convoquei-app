class OrganizationInviteModel {
  final String id;
  final String email;
  final String organization;
  final String invitedBy;
  final DateTime invitedAt;
  final DateTime expiresAt;

  OrganizationInviteModel({
    required this.id,
    required this.email,
    required this.organization,
    required this.invitedBy,
    required this.invitedAt,
    required this.expiresAt,
  });

  factory OrganizationInviteModel.fromJson(Map<String, dynamic> json) {
    return OrganizationInviteModel(
      id: json['id'] as String,
      email: json['email'] as String,
      organization: json['organization'] as String,
      invitedBy: json['invitedBy'] as String,
      invitedAt: DateTime.parse(json['invitedAt'] as String).toLocal(),
      expiresAt: DateTime.parse(json['expiresAt'] as String).toLocal(),
    );
  }
}