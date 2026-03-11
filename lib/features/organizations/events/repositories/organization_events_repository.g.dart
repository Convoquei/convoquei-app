// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_events_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(organizationEventsRepository)
final organizationEventsRepositoryProvider =
    OrganizationEventsRepositoryProvider._();

final class OrganizationEventsRepositoryProvider
    extends
        $FunctionalProvider<
          OrganizationEventsRepository,
          OrganizationEventsRepository,
          OrganizationEventsRepository
        >
    with $Provider<OrganizationEventsRepository> {
  OrganizationEventsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizationEventsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizationEventsRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrganizationEventsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OrganizationEventsRepository create(Ref ref) {
    return organizationEventsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizationEventsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrganizationEventsRepository>(value),
    );
  }
}

String _$organizationEventsRepositoryHash() =>
    r'c1849a8c5281c32433c1f82b4b907433760004d7';
