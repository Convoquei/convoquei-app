enum OrganizationEventMembershipAvailabilityStatus {
  notAnswered,
  available,
  unavailable;

  static const Map<String, OrganizationEventMembershipAvailabilityStatus> _codeMap = {
    'NOT_ANSWERED': notAnswered,
    'AVAILABLE': available,
    'UNAVAILABLE': unavailable,
  };

  String toCode() => _codeMap.entries.firstWhere((entry) => entry.value == this).key;

  static OrganizationEventMembershipAvailabilityStatus fromCode(String code) {
    return _codeMap[code.toUpperCase()] ?? OrganizationEventMembershipAvailabilityStatus.notAnswered;
  }
}