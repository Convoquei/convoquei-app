// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_all_functions_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FunctionsNotifier)
final functionsProvider = FunctionsNotifierProvider._();

final class FunctionsNotifierProvider
    extends
        $NotifierProvider<
          FunctionsNotifier,
          StateListPaged<OrganizationFunctionModel>
        > {
  FunctionsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'functionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$functionsNotifierHash();

  @$internal
  @override
  FunctionsNotifier create() => FunctionsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StateListPaged<OrganizationFunctionModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<StateListPaged<OrganizationFunctionModel>>(value),
    );
  }
}

String _$functionsNotifierHash() => r'108cf6ef5f7c91a20e8862ed5efce7fef980e669';

abstract class _$FunctionsNotifier
    extends $Notifier<StateListPaged<OrganizationFunctionModel>> {
  StateListPaged<OrganizationFunctionModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              StateListPaged<OrganizationFunctionModel>,
              StateListPaged<OrganizationFunctionModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                StateListPaged<OrganizationFunctionModel>,
                StateListPaged<OrganizationFunctionModel>
              >,
              StateListPaged<OrganizationFunctionModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
