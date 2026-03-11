// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_role_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(organizationRoleRepository)
final organizationRoleRepositoryProvider =
    OrganizationRoleRepositoryProvider._();

final class OrganizationRoleRepositoryProvider
    extends
        $FunctionalProvider<
          OrganizationRoleRepository,
          OrganizationRoleRepository,
          OrganizationRoleRepository
        >
    with $Provider<OrganizationRoleRepository> {
  OrganizationRoleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizationRoleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizationRoleRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrganizationRoleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OrganizationRoleRepository create(Ref ref) {
    return organizationRoleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizationRoleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrganizationRoleRepository>(value),
    );
  }
}

String _$organizationRoleRepositoryHash() =>
    r'b371c67ab4430b762cf1b4156fe053b6cdc0f00a';
