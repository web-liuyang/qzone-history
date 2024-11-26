import 'package:qzone/repositories/base_repository.dart';

import 'entities/entities.dart';

class MessageRepository extends BaseRepository<List<Message>, List<dynamic>> {
  MessageRepository({required super.path});

  @override
  List<Message> fromJson(List<dynamic> data) {
    return data.map((e) => Message.fromJson(e)).toList();
  }
}
