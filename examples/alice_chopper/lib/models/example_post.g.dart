// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamplePost _$ExamplePostFromJson(Map<String, dynamic> json) => ExamplePost(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      body: json['body'] as String,
      userId: (json['userId'] as num).toInt(),
    );

Map<String, dynamic> _$ExamplePostToJson(ExamplePost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'userId': instance.userId,
    };
