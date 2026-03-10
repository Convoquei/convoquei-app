// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_availability_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnswerAvailabilityNotifier)
final answerAvailabilityProvider = AnswerAvailabilityNotifierProvider._();

final class AnswerAvailabilityNotifierProvider
    extends
        $NotifierProvider<AnswerAvailabilityNotifier, AnswerAvailabilityState> {
  AnswerAvailabilityNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'answerAvailabilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$answerAvailabilityNotifierHash();

  @$internal
  @override
  AnswerAvailabilityNotifier create() => AnswerAvailabilityNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnswerAvailabilityState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnswerAvailabilityState>(value),
    );
  }
}

String _$answerAvailabilityNotifierHash() =>
    r'dd3d86cf6eb1d9ed6d6d229bf74e04c24743b382';

abstract class _$AnswerAvailabilityNotifier
    extends $Notifier<AnswerAvailabilityState> {
  AnswerAvailabilityState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AnswerAvailabilityState, AnswerAvailabilityState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnswerAvailabilityState, AnswerAvailabilityState>,
              AnswerAvailabilityState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
