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
    extends $AsyncNotifierProvider<AnswerAvailabilityNotifier, void> {
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
}

String _$answerAvailabilityNotifierHash() =>
    r'c67ff8642ab3bb9d167481c9d472e6640df724c5';

abstract class _$AnswerAvailabilityNotifier extends $AsyncNotifier<void> {
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
