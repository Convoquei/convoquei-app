// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_availability_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RequestAvailability)
final requestAvailabilityProvider = RequestAvailabilityProvider._();

final class RequestAvailabilityProvider
    extends $NotifierProvider<RequestAvailability, Map<String, DateTime>> {
  RequestAvailabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestAvailabilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestAvailabilityHash();

  @$internal
  @override
  RequestAvailability create() => RequestAvailability();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, DateTime>>(value),
    );
  }
}

String _$requestAvailabilityHash() =>
    r'3d4a6b47b64bcd27a0958368e1d8f52fbe0c882e';

abstract class _$RequestAvailability extends $Notifier<Map<String, DateTime>> {
  Map<String, DateTime> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, DateTime>, Map<String, DateTime>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, DateTime>, Map<String, DateTime>>,
              Map<String, DateTime>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
