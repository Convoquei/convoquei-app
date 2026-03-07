enum OrganizationPermissionEnum {
  owner,
  member,
  inviteMembers,
  kickMembers,
  manageGroups,
  manageFunctions;

  static const Map<String, OrganizationPermissionEnum> _codeMap = {
    'OWNER': owner,
    'MEMBER': member,
    'INVITE_ORGANIZATION_MEMBERS': inviteMembers,
    'KICK_ORGANIZATION_MEMBER': kickMembers,
    'MANAGE_GROUPS': manageGroups,
    'MANAGE_FUNCTIONS': manageFunctions,
  };

  static OrganizationPermissionEnum fromCode(String code) {
    return _codeMap[code.toUpperCase()] ?? OrganizationPermissionEnum.member;
  }

  static final Map<OrganizationPermissionEnum, String> _reverseCodeMap = {
    for (final entry in _codeMap.entries) entry.value: entry.key,
  };

  String toCode() => _reverseCodeMap[this] ?? name.toUpperCase();
}
