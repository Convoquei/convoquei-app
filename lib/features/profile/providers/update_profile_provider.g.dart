// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UpdateProfileNotifier)
final updateProfileProvider = UpdateProfileNotifierProvider._();

final class UpdateProfileNotifierProvider
    extends $AsyncNotifierProvider<UpdateProfileNotifier, void> {
  UpdateProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProfileNotifierHash();

  @$internal
  @override
  UpdateProfileNotifier create() => UpdateProfileNotifier();
}

String _$updateProfileNotifierHash() =>
    r'cb5740c1d79fdbf3c300e5bd25ad1d7164cfca4c';

abstract class _$UpdateProfileNotifier extends $AsyncNotifier<void> {
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
