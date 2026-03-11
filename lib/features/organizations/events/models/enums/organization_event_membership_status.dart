enum OrganizationEventMembershipStatus {
  pending,
  awaitingAssignment,
  awaitingDraw,
  assigned,
  notAssigned,
  expired;

  static const Map<String, OrganizationEventMembershipStatus> _codeMap = {
    'PENDING': pending,
    'AWAITING_ASSIGNMENT': awaitingAssignment,
    'AWAITING_DRAW': awaitingDraw,
    'ASSIGNED': assigned,
    'NOT_ASSIGNED': notAssigned,
    'EXPIRED': expired,
  };

  String toCode() => _codeMap.entries.firstWhere((entry) => entry.value == this).key;

  static OrganizationEventMembershipStatus fromCode(String code) {
    return _codeMap[code.toUpperCase()] ?? OrganizationEventMembershipStatus.pending;
  }
}