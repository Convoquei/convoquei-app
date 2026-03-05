enum OrganizationPermissionEnum {
  owner,
  member,
  inviteMembers,
  manageGroups,
  kickMembers;

  /// Maps API codes (e.g. `"INVITE_MEMBERS"`) to the corresponding enum value.
  /// Falls back to [member] for unknown codes.
  static const Map<String, OrganizationPermissionEnum> _codeMap = {
    'OWNER': owner,
    'MEMBER': member,
    'INVITE_MEMBERS': inviteMembers,
    'MANAGE_GROUPS': manageGroups,
    'KICK_MEMBERS': kickMembers,
  };

  static OrganizationPermissionEnum fromCode(String code) {
    return _codeMap[code.toUpperCase()] ?? OrganizationPermissionEnum.member;
  }
}
