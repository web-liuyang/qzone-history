import 'package:json_annotation/json_annotation.dart';

import 'comment.dart';
import 'content.dart';

part 'moment.g.dart';

@JsonSerializable()
class Moment {
  const Moment({
    required this.id,
    required this.likes,
    required this.content,
    required this.comments,
  });

  final String id;
  final List<String> likes;
  final List<Comment> comments;
  final Content content;
  // final String time;

  factory Moment.fromJson(Map<String, dynamic> json) => _$MomentFromJson(json);

  Map<String, dynamic> toJson() => _$MomentToJson(this);

  Moment copyWith({
    String? id,
    List<String>? likes,
    List<Comment>? comments,
    Content? content,
  }) {
    return Moment(
      id: id ?? this.id,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      content: content ?? this.content,
    );
  }
}
