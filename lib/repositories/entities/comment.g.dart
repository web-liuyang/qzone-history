// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      sender: json['sender'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'sender': instance.sender,
      'content': instance.content,
      'date': instance.date,
    };
