enum OrganizationEventMembershipAvailabilityStatus {
  notAnswered,
  available,
  unavailable;

  static const Map<String, OrganizationEventMembershipAvailabilityStatus> _codeMap = {
    'NOT_ANSWERED': notAnswered,
    'AVAILABLE': available,
    'UNAVAILABLE': unavailable,
  };

  static OrganizationEventMembershipAvailabilityStatus fromCode(String code) {
    return _codeMap[code.toUpperCase()] ?? OrganizationEventMembershipAvailabilityStatus.notAnswered;
  }
}