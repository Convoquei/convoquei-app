import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';

class OrganizationMyMemberProfile {
  final String name;
  final String avatarUrl;
  final String status;
  final List<OrganizationPermissionEnum> permissions;

  const OrganizationMyMemberProfile({
    required this.name,
    required this.avatarUrl,
    required this.status,
    required this.permissions,
  });

  bool get isOwner => permissions.contains(OrganizationPermissionEnum.owner);

  factory OrganizationMyMemberProfile.fromJson(Map<String, dynamic> json) {
    final rawPerms = json['permissions'] as List<dynamic>? ?? [];
    return OrganizationMyMemberProfile(
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      status: json['status'] as String? ?? '',
      permissions: rawPerms
          .map(
            (p) => OrganizationPermissionEnum.fromCode(
              (p as Map<String, dynamic>)['code'] as String,
            ),
          )
          .toList(),
    );
  }

  bool hasPermission(OrganizationPermissionEnum permission) {
    if (isOwner) return true;
    return permissions.contains(permission);
  }
}
