import 'package:alice/src/utils/json_to_dart_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JsonToDartGenerator', () {
    test('generates class from simple map', () {
      final json = {'id': 1, 'name': 'Alice', 'is_active': true, 'score': 99.5};
      final code = JsonToDartGenerator.generate(json, rootClassName: 'User');

      expect(code, contains('class User {'));
      expect(code, contains('final int id;'));
      expect(code, contains('final String name;'));
      expect(code, contains('final bool isActive;'));
      expect(code, contains('final double score;'));
      expect(
        code,
        contains('factory User.fromJson(Map<String, dynamic> json)'),
      );
      expect(code, contains('Map<String, dynamic> toJson()'));
    });

    test('generates nested classes and list of objects', () {
      final json = {
        'total': 1,
        'author': {'id': 10, 'username': 'jhomlala'},
        'posts': [
          {'title': 'Alice', 'likes': 50},
        ],
      };
      final code = JsonToDartGenerator.generate(json, rootClassName: 'Blog');

      expect(code, contains('class Blog {'));
      expect(code, contains('class Author {'));
      expect(code, contains('class Post {'));
      expect(code, contains('final Author author;'));
      expect(code, contains('final List<Post> posts;'));
    });

    test('handles reserved words as field names', () {
      final json = {'default': true, 'class': 'Math101'};
      final code = JsonToDartGenerator.generate(json, rootClassName: 'Config');

      expect(code, contains('final bool defaultValue;'));
      expect(code, contains('final String classValue;'));
      expect(code, contains('defaultValue: json[\'default\'] as bool'));
      expect(code, contains('classValue: json[\'class\'] as String'));
    });

    test('handles nullable fields correctly', () {
      final json = {'id': 1, 'nickname': null};
      final code = JsonToDartGenerator.generate(json, rootClassName: 'Profile');

      expect(code, contains('final int id;'));
      expect(code, contains('final dynamic nickname;'));
      expect(code, contains('id: json[\'id\'] as int'));
      expect(code, contains('nickname: json[\'nickname\']'));
    });
  });
}
