enum OrganizationEventMembershipStatus {
  pending,
  invited,
  awaitingAssignment,
  assigned,
  notAssigned,
  expired;

  static const Map<String, OrganizationEventMembershipStatus> _codeMap = {
    'PENDING': pending,
    'INVITED': invited,
    'AWAITING_ASSIGNMENT': awaitingAssignment,
    'ASSIGNED': assigned,
    'NOT_ASSIGNED': notAssigned,
    'EXPIRED': expired,
  };

  String toCode() =>
      _codeMap.entries.firstWhere((entry) => entry.value == this).key;

  static OrganizationEventMembershipStatus fromCode(String code) {
    return _codeMap[code.toUpperCase()] ??
        OrganizationEventMembershipStatus.pending;
  }
}
