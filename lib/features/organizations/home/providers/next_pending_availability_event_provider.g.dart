// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_pending_availability_event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(nextPendingAvailabilityEvent)
final nextPendingAvailabilityEventProvider =
    NextPendingAvailabilityEventFamily._();

final class NextPendingAvailabilityEventProvider
    extends
        $FunctionalProvider<
          AsyncValue<OrganizationEventMembershipModel?>,
          OrganizationEventMembershipModel?,
          FutureOr<OrganizationEventMembershipModel?>
        >
    with
        $FutureModifier<OrganizationEventMembershipModel?>,
        $FutureProvider<OrganizationEventMembershipModel?> {
  NextPendingAvailabilityEventProvider._({
    required NextPendingAvailabilityEventFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'nextPendingAvailabilityEventProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nextPendingAvailabilityEventHash();

  @override
  String toString() {
    return r'nextPendingAvailabilityEventProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OrganizationEventMembershipModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OrganizationEventMembershipModel?> create(Ref ref) {
    final argument = this.argument as String;
    return nextPendingAvailabilityEvent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NextPendingAvailabilityEventProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nextPendingAvailabilityEventHash() =>
    r'216b5031ff04c1b99e990f20641cd7d934e7e336';

final class NextPendingAvailabilityEventFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<OrganizationEventMembershipModel?>,
          String
        > {
  NextPendingAvailabilityEventFamily._()
    : super(
        retry: null,
        name: r'nextPendingAvailabilityEventProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NextPendingAvailabilityEventProvider call(String organizationId) =>
      NextPendingAvailabilityEventProvider._(
        argument: organizationId,
        from: this,
      );

  @override
  String toString() => r'nextPendingAvailabilityEventProvider';
}
