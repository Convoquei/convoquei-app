// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UpdateEventNotifier)
final updateEventProvider = UpdateEventNotifierProvider._();

final class UpdateEventNotifierProvider
    extends $AsyncNotifierProvider<UpdateEventNotifier, void> {
  UpdateEventNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateEventProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateEventNotifierHash();

  @$internal
  @override
  UpdateEventNotifier create() => UpdateEventNotifier();
}

String _$updateEventNotifierHash() =>
    r'3b69bce2d79416e1b809872cf95e354cfa658d5e';

abstract class _$UpdateEventNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
