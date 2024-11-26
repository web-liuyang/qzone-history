import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  const Message({
    required this.sender,
    required this.content,
    required this.date,
  });

  final String sender;
  final String content;
  final String date;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    String? sender,
    String? content,
    String? date,
  }) {
    return Message(
      sender: sender ?? this.sender,
      content: content ?? this.content,
      date: date ?? this.date,
    );
  }
}
