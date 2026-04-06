import 'package:convoquei_app/features/organizations/shared/models/organization_role_permission_model.dart';

class OrganizationRoleModel {
  final String id;
  final String name;
  final bool isSystem;
  final List<OrganizationRolePermissionModel> permissions;

  int get permissionCount => permissions.length;

  OrganizationRoleModel({
    required this.id,
    required this.name,
    required this.isSystem,
    required this.permissions,
  });

  factory OrganizationRoleModel.fromJson(Map<String, dynamic> json) {
    return OrganizationRoleModel(
      id: json['id'],
      name: json['name'],
      isSystem: json['isSystem'] ?? false,
      permissions: (json['permissions'] as List<dynamic>)
          .map((permJson) => OrganizationRolePermissionModel.fromJson(permJson))
          .toList(),
    );
  }

  OrganizationRoleModel copyWith({
    String? id,
    String? name,
    bool? isSystem,
    List<OrganizationRolePermissionModel>? permissions,
  }) {
    return OrganizationRoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isSystem: isSystem ?? this.isSystem,
      permissions: permissions ?? this.permissions,
    );
  }
}