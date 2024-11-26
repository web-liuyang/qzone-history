import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

part 'content.g.dart';

@JsonSerializable()
class Content {
  const Content({
    required this.images,
    required this.videos,
    required this.content,
  });

  final List<String> images;
  final List<String> videos;
  final String content;

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);

  Map<String, dynamic> toJson() => _$ContentToJson(this);

  bool get isEmpty => images.isEmpty && content.isEmpty;

  Content copyWith({
    List<String>? images,
    List<String>? videos,
    String? content,
  }) {
    return Content(
      images: images ?? this.images,
      videos: videos ?? this.videos,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Content &&
        const ListEquality<String>().equals(other.images, images) &&
        const ListEquality<String>().equals(other.videos, videos) &&
        other.content == content;
  }
  
  @override
  int get hashCode => Object.hash(images, videos, content);
  
}
