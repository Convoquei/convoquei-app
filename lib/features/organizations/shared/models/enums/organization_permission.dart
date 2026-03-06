enum OrganizationPermissionEnum {
  owner,
  member,
  inviteMembers,
  kickMembers,
  manageGroups;

  static const Map<String, OrganizationPermissionEnum> _codeMap = {
    'OWNER': owner,
    'MEMBER': member,
    'INVITE_ORGANIZATION_MEMBERS': inviteMembers,
    'KICK_ORGANIZATION_MEMBER': kickMembers,
    'MANAGE_GROUPS': manageGroups,
  };

  static OrganizationPermissionEnum fromCode(String code) {
    return _codeMap[code.toUpperCase()] ?? OrganizationPermissionEnum.member;
  }
}
