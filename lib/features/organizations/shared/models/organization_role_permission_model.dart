import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';

class OrganizationRolePermissionModel {
  final String code;
  final String title;
  final String description;

  OrganizationRolePermissionModel({
    required this.code,
    required this.title,
    required this.description,
  });

  static final Map<String, OrganizationPermissionEnum> _permissionMap = {
    for (final e in OrganizationPermissionEnum.values) e.name: e
  };

  OrganizationPermissionEnum get permission =>
      _permissionMap[code] ?? OrganizationPermissionEnum.member;

  factory OrganizationRolePermissionModel.fromJson(Map<String, dynamic> json) {
    return OrganizationRolePermissionModel(
      code: json['code'],
      title: json['title'],
      description: json['description'],
    );
  }
}