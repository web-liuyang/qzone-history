import 'package:qzone/repositories/base_repository.dart';

import 'entities/entities.dart';

class LoginUserRepository extends BaseRepository<LoginUser, Map<String, dynamic>> {
  LoginUserRepository({required super.path});

  @override
  LoginUser fromJson(Map<String, dynamic> data) => LoginUser.fromJson(data);
}
