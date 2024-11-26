import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  const User({required this.qq, required this.nickname});

  final String qq;

  final String nickname;

  String get avatar => 'http://q1.qlogo.cn/g?b=qq&nk=$qq&s=100';

  String get link => "https://user.qzone.qq.com/$qq";

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() {
    return 'User{qq: $qq, nickname: $nickname}';
  }
}
