// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_roles_organization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RolesNotifier)
final rolesProvider = RolesNotifierProvider._();

final class RolesNotifierProvider
    extends
        $NotifierProvider<
          RolesNotifier,
          StateListPaged<OrganizationRoleModel>
        > {
  RolesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rolesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rolesNotifierHash();

  @$internal
  @override
  RolesNotifier create() => RolesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StateListPaged<OrganizationRoleModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<StateListPaged<OrganizationRoleModel>>(value),
    );
  }
}

String _$rolesNotifierHash() => r'8d7e1cffd58f9559ed31710f52eca7d42df5fdff';

abstract class _$RolesNotifier
    extends $Notifier<StateListPaged<OrganizationRoleModel>> {
  StateListPaged<OrganizationRoleModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              StateListPaged<OrganizationRoleModel>,
              StateListPaged<OrganizationRoleModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                StateListPaged<OrganizationRoleModel>,
                StateListPaged<OrganizationRoleModel>
              >,
              StateListPaged<OrganizationRoleModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
