// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoLocation _$GeoLocationFromJson(Map<String, dynamic> json) => GeoLocation(
      lat: GeoLocation._stringToDouble(json['lat'] as String),
      lng: GeoLocation._stringToDouble(json['lng'] as String),
    );

Map<String, dynamic> _$GeoLocationToJson(GeoLocation instance) =>
    <String, dynamic>{
      'lat': GeoLocation._doubleToString(instance.lat),
      'lng': GeoLocation._doubleToString(instance.lng),
    };
