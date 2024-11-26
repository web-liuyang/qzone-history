// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Moment _$MomentFromJson(Map<String, dynamic> json) => Moment(
      id: json['id'] as String,
      likes: (json['likes'] as List<dynamic>).map((e) => e as String).toList(),
      content: Content.fromJson(json['content'] as Map<String, dynamic>),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MomentToJson(Moment instance) => <String, dynamic>{
      'id': instance.id,
      'likes': instance.likes,
      'comments': instance.comments,
      'content': instance.content,
    };
