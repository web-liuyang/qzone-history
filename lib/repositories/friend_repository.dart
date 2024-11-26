import 'package:qzone/repositories/base_repository.dart';

import 'entities/entities.dart';

class FriendRepository extends BaseRepository<List<User>, List<dynamic>> {
  FriendRepository({required super.path});

  @override
  List<User> fromJson(List<dynamic> data) => data.map((e) => User.fromJson(e)).toList();
}
