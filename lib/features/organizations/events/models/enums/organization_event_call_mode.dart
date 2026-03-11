enum OrganizationEventCallMode {
  allOrganizationMembers,
  onlySpecifiedGroupMembers;

  static const Map<String, OrganizationEventCallMode> _codeMap = {
    'ALL_ORGANIZATION_MEMBERS': allOrganizationMembers,
    'ONLY_SPECIFIED_GROUP_MEMBERS': onlySpecifiedGroupMembers,
  };

  String toCode() => _codeMap.entries.firstWhere((entry) => entry.value == this).key;

  static OrganizationEventCallMode fromCode(String code) {
    return _codeMap[code.toUpperCase()] ?? OrganizationEventCallMode.allOrganizationMembers;
  }
}
