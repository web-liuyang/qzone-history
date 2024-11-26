// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Content _$ContentFromJson(Map<String, dynamic> json) => Content(
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      videos:
          (json['videos'] as List<dynamic>).map((e) => e as String).toList(),
      content: json['content'] as String,
    );

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
      'images': instance.images,
      'videos': instance.videos,
      'content': instance.content,
    };
