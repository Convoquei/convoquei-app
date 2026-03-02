import '../../../core/app_services.dart';
import '../../../core/loading_controller.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';

class UserController extends LoadingController {
  final UserRepository _repo;

  UserController([UserRepository? repo])
      : _repo = repo ?? AppServices.instance.userRepository {
    run(fetch);
  }

  UserModel? _user;

  UserModel? get user => _user;

  Future<void> fetch() => run(() async {
    _user = await _repo.getProfile();
  });

  Future<void> refresh() => fetch();
}
