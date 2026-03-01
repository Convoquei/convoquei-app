import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';

class UserController extends AsyncNotifier<UserModel> {
  UserRepository get _repo => ref.read(userRepositoryProvider);

  @override
  Future<UserModel> build() => _repo.getProfile();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getProfile());
  }
}

final userControllerProvider =
    AsyncNotifierProvider<UserController, UserModel>(UserController.new);

