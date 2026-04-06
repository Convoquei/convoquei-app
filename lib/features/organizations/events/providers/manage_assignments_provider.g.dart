// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manage_assignments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ManageAssignments)
final manageAssignmentsProvider = ManageAssignmentsProvider._();

final class ManageAssignmentsProvider
    extends $AsyncNotifierProvider<ManageAssignments, void> {
  ManageAssignmentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manageAssignmentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manageAssignmentsHash();

  @$internal
  @override
  ManageAssignments create() => ManageAssignments();
}

String _$manageAssignmentsHash() => r'a6b6ec735ad8b0e83d4be75e1607b0cd3c5d078b';

abstract class _$ManageAssignments extends $AsyncNotifier<void> {
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
