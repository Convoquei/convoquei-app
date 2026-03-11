enum OrganizationEventStatus {
  scheduled,
  inProgress,
  completed,
  canceled;

  static const Map<String, OrganizationEventStatus> _codeMap = {
    'SCHEDULED': scheduled,
    'IN_PROGRESS': inProgress,
    'COMPLETED': completed,
    'CANCELED': canceled,
  };

  String toCode() => _codeMap.entries.firstWhere((e) => e.value == this).key;

  static OrganizationEventStatus fromCode(String code) {
    return _codeMap[code.toUpperCase()] ?? OrganizationEventStatus.scheduled;
  }
}