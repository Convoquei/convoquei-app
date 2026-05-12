// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_all_events_membership_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventMembershipNotifier)
final eventMembershipProvider = EventMembershipNotifierProvider._();

final class EventMembershipNotifierProvider
    extends
        $NotifierProvider<
          EventMembershipNotifier,
          StateListPaged<OrganizationEventMembershipModel>
        > {
  EventMembershipNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventMembershipProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventMembershipNotifierHash();

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
}

String _$eventMembershipNotifierHash() =>
    r'd49aa72ed698f98e357285e28dc15bc0d626beca';

abstract class _$EventMembershipNotifier
    extends $Notifier<StateListPaged<OrganizationEventMembershipModel>> {
  StateListPaged<OrganizationEventMembershipModel> build();
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
    element.handleCreate(ref, build);
  }
}
