// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateEventNotifier)
final createEventProvider = CreateEventNotifierProvider._();

final class CreateEventNotifierProvider
    extends $AsyncNotifierProvider<CreateEventNotifier, void> {
  CreateEventNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createEventProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createEventNotifierHash();

  @$internal
  @override
  CreateEventNotifier create() => CreateEventNotifier();
}

String _$createEventNotifierHash() =>
    r'cd833d21319e740132225fdc0584d063a2b4544e';

abstract class _$CreateEventNotifier extends $AsyncNotifier<void> {
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
