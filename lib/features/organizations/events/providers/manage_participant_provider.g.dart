// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manage_participant_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ManageParticipant)
final manageParticipantProvider = ManageParticipantProvider._();

final class ManageParticipantProvider
    extends $AsyncNotifierProvider<ManageParticipant, void> {
  ManageParticipantProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manageParticipantProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manageParticipantHash();

  @$internal
  @override
  ManageParticipant create() => ManageParticipant();
}

String _$manageParticipantHash() => r'23afe78f9bcc833a1b3424e3c96a4d922198cf7a';

abstract class _$ManageParticipant extends $AsyncNotifier<void> {
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
