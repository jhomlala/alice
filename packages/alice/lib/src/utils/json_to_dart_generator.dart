/// Generator that converts JSON maps/lists into clean Dart 3 data model classes.
class JsonToDartGenerator {
  static const _reservedKeywords = {
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'Function',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield',
  };

  /// Generates Dart class definitions from [json].
  static String generate(
    dynamic json, {
    String rootClassName = 'RootResponse',
  }) {
    if (json == null) {
      return '// Empty JSON';
    }

    dynamic target = json;
    if (json is List) {
      if (json.isEmpty) {
        return '// Empty JSON array';
      }
      for (final item in json) {
        if (item != null) {
          target = item;
          break;
        }
      }
      if (target == null || target is! Map) {
        return '// JSON array of primitives: List<${_inferPrimitiveType(target)}>';
      }
    }

    if (target is! Map) {
      return '// JSON primitive: ${_inferPrimitiveType(target)}';
    }

    final classes = <String, String>{};
    _generateClass(target, rootClassName, classes);

    return classes.values.join('\n\n');
  }

  static void _generateClass(
    Map map,
    String className,
    Map<String, String> classes,
  ) {
    final validClassName = _toPascalCase(className);
    if (classes.containsKey(validClassName)) {
      return;
    }

    final fields = <_FieldInfo>[];

    for (final entry in map.entries) {
      final jsonKey = entry.key.toString();
      final fieldName = _toCamelCase(jsonKey);
      final value = entry.value;

      String typeName;
      if (value == null) {
        typeName = 'dynamic';
      } else if (value is bool) {
        typeName = 'bool';
      } else if (value is int) {
        typeName = 'int';
      } else if (value is double) {
        typeName = 'double';
      } else if (value is num) {
        typeName = 'num';
      } else if (value is String) {
        typeName = 'String';
      } else if (value is Map) {
        final nestedClassName = _toPascalCase(jsonKey);
        _generateClass(value, nestedClassName, classes);
        typeName = nestedClassName;
      } else if (value is List) {
        if (value.isEmpty) {
          typeName = 'List<dynamic>';
        } else {
          dynamic firstItem;
          for (final item in value) {
            if (item != null) {
              firstItem = item;
              break;
            }
          }
          if (firstItem is Map) {
            final nestedClassName = _toSingularPascalCase(jsonKey);
            _generateClass(firstItem, nestedClassName, classes);
            typeName = 'List<$nestedClassName>';
          } else {
            typeName = 'List<${_inferPrimitiveType(firstItem)}>';
          }
        }
      } else {
        typeName = 'dynamic';
      }

      fields.add(
        _FieldInfo(
          jsonKey: jsonKey,
          fieldName: fieldName,
          typeName: typeName,
          isNullable: value == null,
        ),
      );
    }

    final buffer = StringBuffer();
    buffer.writeln('class $validClassName {');

    for (final f in fields) {
      final typeDecl = f.isNullable && f.typeName != 'dynamic'
          ? '${f.typeName}?'
          : f.typeName;
      buffer.writeln('  final $typeDecl ${f.fieldName};');
    }

    buffer.writeln();
    buffer.writeln('  const $validClassName({');
    for (final f in fields) {
      if (f.isNullable || f.typeName == 'dynamic') {
        buffer.writeln('    this.${f.fieldName},');
      } else {
        buffer.writeln('    required this.${f.fieldName},');
      }
    }
    buffer.writeln('  });');

    buffer.writeln();
    buffer.writeln(
      '  factory $validClassName.fromJson(Map<String, dynamic> json) => $validClassName(',
    );
    for (final f in fields) {
      buffer.write('    ${f.fieldName}: ');
      final opt = f.isNullable ? '?' : '';
      if (f.typeName == 'int') {
        buffer.writeln('json[\'${f.jsonKey}\'] as int$opt,');
      } else if (f.typeName == 'double') {
        buffer.writeln(
          f.isNullable
              ? '(json[\'${f.jsonKey}\'] as num?)?.toDouble(),'
              : '(json[\'${f.jsonKey}\'] as num).toDouble(),',
        );
      } else if (f.typeName == 'num') {
        buffer.writeln('json[\'${f.jsonKey}\'] as num$opt,');
      } else if (f.typeName == 'String') {
        buffer.writeln('json[\'${f.jsonKey}\'] as String$opt,');
      } else if (f.typeName == 'bool') {
        buffer.writeln('json[\'${f.jsonKey}\'] as bool$opt,');
      } else if (f.typeName.startsWith('List<') &&
          f.typeName != 'List<dynamic>') {
        final innerType = f.typeName.substring(5, f.typeName.length - 1);
        if (['int', 'double', 'num', 'String', 'bool'].contains(innerType)) {
          buffer.writeln(
            f.isNullable
                ? '(json[\'${f.jsonKey}\'] as List<dynamic>?)?.map((e) => e as $innerType).toList(),'
                : '(json[\'${f.jsonKey}\'] as List<dynamic>).map((e) => e as $innerType).toList(),',
          );
        } else {
          buffer.writeln(
            f.isNullable
                ? '(json[\'${f.jsonKey}\'] as List<dynamic>?)?.map((e) => $innerType.fromJson(e as Map<String, dynamic>)).toList(),'
                : '(json[\'${f.jsonKey}\'] as List<dynamic>).map((e) => $innerType.fromJson(e as Map<String, dynamic>)).toList(),',
          );
        }
      } else if (classes.containsKey(f.typeName)) {
        buffer.writeln(
          f.isNullable
              ? 'json[\'${f.jsonKey}\'] != null ? ${f.typeName}.fromJson(json[\'${f.jsonKey}\'] as Map<String, dynamic>) : null,'
              : '${f.typeName}.fromJson(json[\'${f.jsonKey}\'] as Map<String, dynamic>),',
        );
      } else {
        buffer.writeln('json[\'${f.jsonKey}\'],');
      }
    }
    buffer.writeln('  );');

    buffer.writeln();
    buffer.writeln('  Map<String, dynamic> toJson() => {');
    for (final f in fields) {
      if (classes.containsKey(f.typeName)) {
        buffer.writeln('    \'${f.jsonKey}\': ${f.fieldName}?.toJson(),');
      } else if (f.typeName.startsWith('List<') &&
          !f.typeName.startsWith('List<dynamic>')) {
        final innerType = f.typeName.substring(5, f.typeName.length - 1);
        if (['int', 'double', 'num', 'String', 'bool'].contains(innerType)) {
          buffer.writeln('    \'${f.jsonKey}\': ${f.fieldName},');
        } else {
          buffer.writeln(
            '    \'${f.jsonKey}\': ${f.fieldName}?.map((e) => e.toJson()).toList(),',
          );
        }
      } else {
        buffer.writeln('    \'${f.jsonKey}\': ${f.fieldName},');
      }
    }
    buffer.writeln('  };');
    buffer.write('}');

    classes[validClassName] = buffer.toString();
  }

  static String _inferPrimitiveType(dynamic value) {
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is num) return 'num';
    if (value is bool) return 'bool';
    if (value is String) return 'String';
    return 'dynamic';
  }

  static String _toPascalCase(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final parts = cleaned.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'Model';
    return parts.map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }

  static String _toSingularPascalCase(String input) {
    var pascal = _toPascalCase(input);
    if (pascal.endsWith('ies')) {
      pascal = '${pascal.substring(0, pascal.length - 3)}y';
    } else if (pascal.endsWith('s') && !pascal.endsWith('ss')) {
      pascal = pascal.substring(0, pascal.length - 1);
    }
    return pascal;
  }

  static String _toCamelCase(String input) {
    final pascal = _toPascalCase(input);
    if (pascal.isEmpty) return 'field';
    final camel = pascal[0].toLowerCase() + pascal.substring(1);
    return _reservedKeywords.contains(camel) ? '${camel}Value' : camel;
  }
}

class _FieldInfo {
  final String jsonKey;
  final String fieldName;
  final String typeName;
  final bool isNullable;

  _FieldInfo({
    required this.jsonKey,
    required this.fieldName,
    required this.typeName,
    required this.isNullable,
  });
}
