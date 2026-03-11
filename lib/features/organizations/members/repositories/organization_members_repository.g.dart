// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_members_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(organizationMembersRepository)
final organizationMembersRepositoryProvider =
    OrganizationMembersRepositoryProvider._();

final class OrganizationMembersRepositoryProvider
    extends
        $FunctionalProvider<
          OrganizationMembersRepository,
          OrganizationMembersRepository,
          OrganizationMembersRepository
        >
    with $Provider<OrganizationMembersRepository> {
  OrganizationMembersRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizationMembersRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizationMembersRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrganizationMembersRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OrganizationMembersRepository create(Ref ref) {
    return organizationMembersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizationMembersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrganizationMembersRepository>(
        value,
      ),
    );
  }
}

String _$organizationMembersRepositoryHash() =>
    r'4ae488018064ee8b49d84371a164e46d7a9009e8';
