import '../repositories/entities/entities.dart';
import '../repositories/models/models.dart';
import '../repositories/repositories.dart';

class LoginService {
  LoginService({
    required LoginUserRepository userRepository,
    required LoginUserModel loginUserModel,
  })  : _userRepository = userRepository,
        _userModel = loginUserModel;

  late final LoginUserRepository _userRepository;

  late final LoginUserModel _userModel;

  Future<void> login(LoginUser value) async {
    await _userRepository.create(value);
    _userModel.user = value;
  }

  Future<void> logout() async {
    await _userRepository.delete();
    _userModel.user = null;
  }
}
