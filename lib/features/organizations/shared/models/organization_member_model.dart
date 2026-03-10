import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_function_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_group_model.dart';

class OrganizationMemberModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String status;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final List<OrganizationPermissionEnum> permissions;
  final List<OrganizationMemberGroupModel> groups;
  final List<OrganizationMemberFunctionModel> functions;

  const OrganizationMemberModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
    required this.joinedAt,
    this.leftAt,
    required this.permissions,
    this.groups = const [],
    this.functions = const [],
  });

  OrganizationMemberModel copyWith({
    List<OrganizationMemberGroupModel>? groups,
    List<OrganizationMemberFunctionModel>? functions,
  }) {
    return OrganizationMemberModel(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      status: status,
      joinedAt: joinedAt,
      leftAt: leftAt,
      permissions: permissions,
      groups: groups ?? this.groups,
      functions: functions ?? this.functions,
    );
  }

  factory OrganizationMemberModel.fromJson(Map<String, dynamic> json) {
    final rawPerms = json['permissions'] as List<dynamic>? ?? [];

    return OrganizationMemberModel(
      id: json['id'] as String,
      name: json['userName'] as String,
      avatarUrl: json['userAvatarUrl'] as String,
      status: json['status'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String).toLocal(),
      leftAt: json['leftAt'] != null
          ? DateTime.parse(json['leftAt'] as String).toLocal()
          : null,
      permissions: rawPerms
          .map(
            (p) => OrganizationPermissionEnum.fromCode(
              (p as Map<String, dynamic>)['code'] as String,
            ),
          )
          .toList(),
      groups: (json['groups'] as List<dynamic>? ?? [])
          .map((g) => OrganizationMemberGroupModel.fromJson(g as Map<String, dynamic>))
          .toList(),
      functions: (json['functions'] as List<dynamic>? ?? [])
          .map((f) => OrganizationMemberFunctionModel.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}
