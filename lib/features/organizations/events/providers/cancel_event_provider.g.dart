// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CancelEventNotifier)
final cancelEventProvider = CancelEventNotifierProvider._();

final class CancelEventNotifierProvider
    extends $AsyncNotifierProvider<CancelEventNotifier, void> {
  CancelEventNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cancelEventProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cancelEventNotifierHash();

  @$internal
  @override
  CancelEventNotifier create() => CancelEventNotifier();
}

String _$cancelEventNotifierHash() =>
    r'bd35bfa9b154038d184f7ef3a5d76c861e6b8541';

abstract class _$CancelEventNotifier extends $AsyncNotifier<void> {
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
