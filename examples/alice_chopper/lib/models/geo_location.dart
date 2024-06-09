import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'geo_location.g.dart';

@JsonSerializable()
class GeoLocation with EquatableMixin {
  GeoLocation({
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  GeoLocation copyWith({
    double? lat,
    double? lng,
  }) =>
      GeoLocation(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  factory GeoLocation.fromJson(Map<String, dynamic> json) =>
      _$GeoLocationFromJson(json);

  Map<String, dynamic> toJson() => _$GeoLocationToJson(this);

  @override
  List<Object?> get props => [lat, lng];
}
