import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  const Comment({
    required this.sender,
    required this.content,
    required this.date,
  });

  final String sender;
  final String content;
  final String date;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);

  Comment copyWith({
    String? sender,
    String? content,
    String? date,
  }) {
    return Comment(
      sender: sender ?? this.sender,
      content: content ?? this.content,
      date: date ?? this.date,
    );
  }
}
