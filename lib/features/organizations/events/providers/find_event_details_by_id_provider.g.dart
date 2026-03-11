// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_event_details_by_id_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(findEventDetailsById)
final findEventDetailsByIdProvider = FindEventDetailsByIdFamily._();

final class FindEventDetailsByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<OrganizationEventDetailsModel>,
          OrganizationEventDetailsModel,
          FutureOr<OrganizationEventDetailsModel>
        >
    with
        $FutureModifier<OrganizationEventDetailsModel>,
        $FutureProvider<OrganizationEventDetailsModel> {
  FindEventDetailsByIdProvider._({
    required FindEventDetailsByIdFamily super.from,
    required ({String organizationId, String eventId}) super.argument,
  }) : super(
         retry: null,
         name: r'findEventDetailsByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$findEventDetailsByIdHash();

  @override
  String toString() {
    return r'findEventDetailsByIdProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<OrganizationEventDetailsModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OrganizationEventDetailsModel> create(Ref ref) {
    final argument = this.argument as ({String organizationId, String eventId});
    return findEventDetailsById(
      ref,
      organizationId: argument.organizationId,
      eventId: argument.eventId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FindEventDetailsByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$findEventDetailsByIdHash() =>
    r'a26d6861a89e0fd45eec4c843120d3e5aaf39f7b';

final class FindEventDetailsByIdFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<OrganizationEventDetailsModel>,
          ({String organizationId, String eventId})
        > {
  FindEventDetailsByIdFamily._()
    : super(
        retry: null,
        name: r'findEventDetailsByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FindEventDetailsByIdProvider call({
    required String organizationId,
    required String eventId,
  }) => FindEventDetailsByIdProvider._(
    argument: (organizationId: organizationId, eventId: eventId),
    from: this,
  );

  @override
  String toString() => r'findEventDetailsByIdProvider';
}
