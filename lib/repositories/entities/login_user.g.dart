// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginUser _$LoginUserFromJson(Map<String, dynamic> json) => LoginUser(
      qq: json['qq'] as String,
      nickname: json['nickname'] as String,
      cookies: const ListCookieConverter().fromJson(json['cookies'] as List),
    );

Map<String, dynamic> _$LoginUserToJson(LoginUser instance) => <String, dynamic>{
      'qq': instance.qq,
      'nickname': instance.nickname,
      'cookies': const ListCookieConverter().toJson(instance.cookies),
    };
