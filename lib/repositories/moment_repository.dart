import 'package:qzone/repositories/base_repository.dart';

import 'entities/entities.dart';

class MomentRepository extends BaseRepository<List<Moment>, List<dynamic>> {
  MomentRepository({required super.path});

  @override
  List<Moment> fromJson(List<dynamic> data) {
    return data.map((e) => Moment.fromJson(e)).toList();
  }
}
