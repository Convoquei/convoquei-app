enum OrganizationEventAssignmentMode {
  manual,
  automatic;

  static const Map<String, OrganizationEventAssignmentMode> _codeMap = {
    'MANUAL': manual,
    'AUTOMATIC': automatic
  };

  String toCode() => _codeMap.entries.firstWhere((entry) => entry.value == this).key;

  static OrganizationEventAssignmentMode fromCode(String code) {
    return _codeMap[code.toUpperCase()] ?? OrganizationEventAssignmentMode.manual;
  }
}