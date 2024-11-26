import 'dart:convert';
import 'dart:io';

abstract class BaseRepository<T, K> {
  BaseRepository({
    required String path,
  }) {
    _file = File(path);
  }

  late final File _file;

  T fromJson(K data);

  Future<void> create(T data) async {
    final json = jsonEncode(data);
    await _file.writeAsString(json);
  }

  Future<T?> read() async {
    if (!_file.existsSync()) return null;
    try {
      final json = await _file.readAsString();
      final data = jsonDecode(json);
      final result = fromJson(data);
      return result;
    } catch (e) {
      print("Read File Failed: $e");
      return null;
    }
  }

  Future<void> update(T data) async {
    final json = jsonEncode(data);
    await _file.writeAsString(json);
  }

  Future<void> delete() async {
    await _file.delete();
  }
}
