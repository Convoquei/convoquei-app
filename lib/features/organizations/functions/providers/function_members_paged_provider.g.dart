// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'function_members_paged_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FunctionMembers)
final functionMembersProvider = FunctionMembersFamily._();

final class FunctionMembersProvider
    extends
        $AsyncNotifierProvider<
          FunctionMembers,
          List<OrganizationFunctionMemberModel>
        > {
  FunctionMembersProvider._({
    required FunctionMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'functionMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$functionMembersHash();

  @override
  String toString() {
    return r'functionMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FunctionMembers create() => FunctionMembers();

  @override
  bool operator ==(Object other) {
    return other is FunctionMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$functionMembersHash() => r'b93040ea94a23fd65601c3ebb9aa6a9fd6f5ec59';

final class FunctionMembersFamily extends $Family
    with
        $ClassFamilyOverride<
          FunctionMembers,
          AsyncValue<List<OrganizationFunctionMemberModel>>,
          List<OrganizationFunctionMemberModel>,
          FutureOr<List<OrganizationFunctionMemberModel>>,
          String
        > {
  FunctionMembersFamily._()
    : super(
        retry: null,
        name: r'functionMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FunctionMembersProvider call(String functionId) =>
      FunctionMembersProvider._(argument: functionId, from: this);

  @override
  String toString() => r'functionMembersProvider';
}

abstract class _$FunctionMembers
    extends $AsyncNotifier<List<OrganizationFunctionMemberModel>> {
  late final _$args = ref.$arg as String;
  String get functionId => _$args;

  FutureOr<List<OrganizationFunctionMemberModel>> build(String functionId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<OrganizationFunctionMemberModel>>,
              List<OrganizationFunctionMemberModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<OrganizationFunctionMemberModel>>,
                List<OrganizationFunctionMemberModel>
              >,
              AsyncValue<List<OrganizationFunctionMemberModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
