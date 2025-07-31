import 'package:alice/model/alice_from_data_field.dart';
import 'package:json_annotation/json_annotation.dart';

/// Convert [AliceFormDataField] to and from JSON.
class AliceFormDataFieldConverter
    implements JsonConverter<AliceFormDataField, Map<String, dynamic>> {
  const AliceFormDataFieldConverter();

  /// Instance of [AliceFormDataFieldConverter].
  static const AliceFormDataFieldConverter instance =
      AliceFormDataFieldConverter();

  @override
  AliceFormDataField fromJson(Map<String, dynamic> json) =>
      AliceFormDataField(json['name'] as String, json['value'] as String);

  @override
  Map<String, dynamic> toJson(AliceFormDataField object) => <String, dynamic>{
    'name': object.name,
    'value': object.value,
  };
}
