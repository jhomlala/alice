import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invalid_model.g.dart';

@JsonSerializable()
class InvalidModel with EquatableMixin {
  const InvalidModel({this.id});

  // should be `int?` but we want to test the error
  final String? id;

  InvalidModel copyWith({String? id}) => InvalidModel(id: id ?? this.id);

  factory InvalidModel.fromJson(Map<String, dynamic> json) =>
      _$InvalidModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvalidModelToJson(this);

  @override
  List<Object?> get props => [id];
}
