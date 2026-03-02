import 'package:convoquei_app/features/organizations/enums/organization_status_enum.dart';

class OrganizationModel {
  final String id;
  final String name;
  final String slug;
  final String photoUrl;
  final OrganizationStatusEnum status;
  final String totalMembers;
  final DateTime createdAt;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.photoUrl,
    required this.status,
    required this.totalMembers,
    required this.createdAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      photoUrl: json['photoUrl'] as String,
      status: OrganizationStatusEnum.values.firstWhere((e) => e.name == json['status']),
      totalMembers: json['totalMembers'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}