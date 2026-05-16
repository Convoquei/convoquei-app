// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_all_events_membership_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventMembershipNotifier)
final eventMembershipProvider = EventMembershipNotifierFamily._();

final class EventMembershipNotifierProvider
    extends
        $NotifierProvider<
          EventMembershipNotifier,
          StateListPaged<OrganizationEventMembershipModel>
        > {
  EventMembershipNotifierProvider._({
    required EventMembershipNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventMembershipProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventMembershipNotifierHash();

  @override
  String toString() {
    return r'eventMembershipProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventMembershipNotifier create() => EventMembershipNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    StateListPaged<OrganizationEventMembershipModel> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<StateListPaged<OrganizationEventMembershipModel>>(
            value,
          ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventMembershipNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventMembershipNotifierHash() =>
    r'9428fcd9676c0cc694cbc49673647bc3488f485d';

final class EventMembershipNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          EventMembershipNotifier,
          StateListPaged<OrganizationEventMembershipModel>,
          StateListPaged<OrganizationEventMembershipModel>,
          StateListPaged<OrganizationEventMembershipModel>,
          String
        > {
  EventMembershipNotifierFamily._()
    : super(
        retry: null,
        name: r'eventMembershipProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventMembershipNotifierProvider call(String organizationId) =>
      EventMembershipNotifierProvider._(argument: organizationId, from: this);

  @override
  String toString() => r'eventMembershipProvider';
}

abstract class _$EventMembershipNotifier
    extends $Notifier<StateListPaged<OrganizationEventMembershipModel>> {
  late final _$args = ref.$arg as String;
  String get organizationId => _$args;

  StateListPaged<OrganizationEventMembershipModel> build(String organizationId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              StateListPaged<OrganizationEventMembershipModel>,
              StateListPaged<OrganizationEventMembershipModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                StateListPaged<OrganizationEventMembershipModel>,
                StateListPaged<OrganizationEventMembershipModel>
              >,
              StateListPaged<OrganizationEventMembershipModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
