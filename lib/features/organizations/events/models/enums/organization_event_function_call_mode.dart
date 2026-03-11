enum OrganizationEventFunctionCallMode {
  onlyMembersWithListedFunctions,
  allMembersWithFunctionLimits;

  static const Map<String, OrganizationEventFunctionCallMode> _codeMap = {
    'ONLY_MEMBERS_WITH_LISTED_FUNCTIONS': onlyMembersWithListedFunctions,
    'ALL_MEMBERS_WITH_FUNCTION_LIMITS': allMembersWithFunctionLimits,
  };

  String toCode() => _codeMap.entries.firstWhere((entry) => entry.value == this).key;

  static OrganizationEventFunctionCallMode fromCode(String code) {
    return _codeMap[code.toUpperCase()] ??
        OrganizationEventFunctionCallMode.onlyMembersWithListedFunctions;
  }
}
