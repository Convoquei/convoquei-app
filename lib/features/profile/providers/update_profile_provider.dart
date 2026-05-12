import 'package:convoquei_app/features/auth/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_profile_provider.g.dart';

@riverpod
class UpdateProfileNotifier extends _$UpdateProfileNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> save({required String name}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).updateProfile(name: name);
      await ref.read(authProvider.notifier).refreshProfile();
    });
  }
}
