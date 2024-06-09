import 'package:json_annotation/json_annotation.dart';

part 'example_post.g.dart';

@JsonSerializable()
class ExamplePost {
  final int? id;
  final String title;
  final String body;
  final int userId;

  const ExamplePost({
    this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  ExamplePost copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
  }) =>
      ExamplePost(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        userId: userId ?? this.userId,
      );

  factory ExamplePost.fromJson(Map<String, dynamic> json) =>
      _$ExamplePostFromJson(json);

  Map<String, dynamic> toJson() => _$ExamplePostToJson(this);
}
