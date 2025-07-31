import 'package:alice/model/alice_form_data_file.dart';
import 'package:json_annotation/json_annotation.dart';

/// Convert [AliceFormDataFile] to and from JSON.
class AliceFormDataFileConverter
    implements JsonConverter<AliceFormDataFile, Map<String, dynamic>> {
  const AliceFormDataFileConverter();

  /// Instance of [AliceFormDataFileConverter].
  static const AliceFormDataFileConverter instance =
      AliceFormDataFileConverter();

  @override
  AliceFormDataFile fromJson(Map<String, dynamic> json) => AliceFormDataFile(
    json['fileName'] as String?,
    json['contentType'] as String,
    (json['length'] as num).toInt(),
  );

  @override
  Map<String, dynamic> toJson(AliceFormDataFile object) => <String, dynamic>{
    'fileName': object.fileName,
    'contentType': object.contentType,
    'length': object.length,
  };
}
