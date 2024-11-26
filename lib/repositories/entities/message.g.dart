// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      sender: json['sender'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'sender': instance.sender,
      'content': instance.content,
      'date': instance.date,
    };
