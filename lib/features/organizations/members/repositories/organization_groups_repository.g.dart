// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_groups_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(organizationGroupsRepository)
final organizationGroupsRepositoryProvider =
    OrganizationGroupsRepositoryProvider._();

final class OrganizationGroupsRepositoryProvider
    extends
        $FunctionalProvider<
          OrganizationGroupsRepository,
          OrganizationGroupsRepository,
          OrganizationGroupsRepository
        >
    with $Provider<OrganizationGroupsRepository> {
  OrganizationGroupsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizationGroupsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizationGroupsRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrganizationGroupsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OrganizationGroupsRepository create(Ref ref) {
    return organizationGroupsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizationGroupsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrganizationGroupsRepository>(value),
    );
  }
}

String _$organizationGroupsRepositoryHash() =>
    r'e00491956b9d57afc1dad08959ba8c3efa171bf0';
