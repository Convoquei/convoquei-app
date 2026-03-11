// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_functions_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(organizationFunctionsRepository)
final organizationFunctionsRepositoryProvider =
    OrganizationFunctionsRepositoryProvider._();

final class OrganizationFunctionsRepositoryProvider
    extends
        $FunctionalProvider<
          OrganizationFunctionsRepository,
          OrganizationFunctionsRepository,
          OrganizationFunctionsRepository
        >
    with $Provider<OrganizationFunctionsRepository> {
  OrganizationFunctionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizationFunctionsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizationFunctionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrganizationFunctionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OrganizationFunctionsRepository create(Ref ref) {
    return organizationFunctionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizationFunctionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrganizationFunctionsRepository>(
        value,
      ),
    );
  }
}

String _$organizationFunctionsRepositoryHash() =>
    r'260d4a7a8202a19e6bd9b864eb07d289b2f67415';
