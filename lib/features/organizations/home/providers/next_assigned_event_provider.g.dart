// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_assigned_event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(nextAssignedEvent)
final nextAssignedEventProvider = NextAssignedEventFamily._();

final class NextAssignedEventProvider
    extends
        $FunctionalProvider<
          AsyncValue<OrganizationEventMembershipModel?>,
          OrganizationEventMembershipModel?,
          FutureOr<OrganizationEventMembershipModel?>
        >
    with
        $FutureModifier<OrganizationEventMembershipModel?>,
        $FutureProvider<OrganizationEventMembershipModel?> {
  NextAssignedEventProvider._({
    required NextAssignedEventFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'nextAssignedEventProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nextAssignedEventHash();

  @override
  String toString() {
    return r'nextAssignedEventProvider'
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
    return nextAssignedEvent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NextAssignedEventProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nextAssignedEventHash() => r'8aed246c0c6d6cabd20b952db99b4d8bee7b521e';

final class NextAssignedEventFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<OrganizationEventMembershipModel?>,
          String
        > {
  NextAssignedEventFamily._()
    : super(
        retry: null,
        name: r'nextAssignedEventProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NextAssignedEventProvider call(String organizationId) =>
      NextAssignedEventProvider._(argument: organizationId, from: this);

  @override
  String toString() => r'nextAssignedEventProvider';
}
