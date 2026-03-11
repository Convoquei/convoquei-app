import 'package:convoquei_app/features/organizations/shared/models/enums/organization_status_enum.dart';

class OrganizationModel {
  final String id;
  final String name;
  final String slug;
  final String photoUrl;
  final OrganizationStatusEnum status;
  final int totalMembers;
  final DateTime createdAt;

  final bool hasAutoScheduleFeature;
  final bool hasRecurrencyFeature;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.photoUrl,
    required this.status,
    required this.totalMembers,
    required this.createdAt,
    this.hasAutoScheduleFeature = true,
    this.hasRecurrencyFeature = true,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      photoUrl: json['photoUrl'] as String,
      status: OrganizationStatusEnum.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['status'] as String).toLowerCase(),
        orElse: () => OrganizationStatusEnum.active,
      ),
      totalMembers: json['totalMembers'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      // hasAutoScheduleFeature: json['hasAutoScheduleFeature'] as bool? ?? false,
      // hasRecurrencyFeature: json['hasRecurrencyFeature'] as bool? ?? false,
    );
  }
}