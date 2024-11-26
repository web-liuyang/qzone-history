import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

import '../../utils/utils.dart';
import 'user.dart';

part 'login_user.g.dart';

class ListCookieConverter implements JsonConverter<List<Cookie>, List<dynamic>> {
  const ListCookieConverter();

  @override
  List<Cookie> fromJson(List<dynamic> json) {
    final list = json.cast<String>();
    return resolveCookiesFromArray(list);
  }

  @override
  List<String> toJson(List<Cookie> cookies) {
    return cookies.map((c) => c.toString()).toList();
  }
}

@JsonSerializable()
class LoginUser extends User {
  const LoginUser({
    required super.qq,
    required super.nickname,
    required this.cookies,
  });

  @ListCookieConverter()
  final List<Cookie> cookies;

  String get gTk => "${bkn(cookies.getValue("p_skey")!)}";

  factory LoginUser.mock() {
    return const LoginUser(qq: "984584014", nickname: "LiuYang Mock", cookies: []);
  }

  factory LoginUser.fromJson(Map<String, dynamic> json) => _$LoginUserFromJson(json);

  Map<String, dynamic> toJson() => _$LoginUserToJson(this);
}
