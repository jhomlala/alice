import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'geo_location.g.dart';

@JsonSerializable()
class GeoLocation with EquatableMixin {
  const GeoLocation({
    required this.lat,
    required this.lng,
  });

  @JsonKey(
    fromJson: GeoLocation._stringToDouble,
    toJson: GeoLocation._doubleToString,
  )
  final double lat;
  @JsonKey(
    fromJson: GeoLocation._stringToDouble,
    toJson: GeoLocation._doubleToString,
  )
  final double lng;

  GeoLocation copyWith({
    double? lat,
    double? lng,
  }) =>
      GeoLocation(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  static String _doubleToString(double value) => value.toString();

  static double _stringToDouble(String value) => double.tryParse(value) ?? 0;

  factory GeoLocation.fromJson(Map<String, dynamic> json) =>
      _$GeoLocationFromJson(json);

  Map<String, dynamic> toJson() => _$GeoLocationToJson(this);

  @override
  List<Object?> get props => [lat, lng];
}
