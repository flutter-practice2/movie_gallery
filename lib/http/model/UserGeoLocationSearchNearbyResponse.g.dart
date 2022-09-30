// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserGeoLocationSearchNearbyResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserGeoLocationSearchNearbyResponse
    _$UserGeoLocationSearchNearbyResponseFromJson(Map<String, dynamic> json) =>
        UserGeoLocationSearchNearbyResponse(
          pageNumber: json['pageNumber'] as int?,
          pageSize: json['pageSize'] as int?,
          total: json['total'] as int?,
          list: (json['list'] as List<dynamic>?)
              ?.map((e) =>
                  UserLocationProjection.fromJson(e as Map<String, dynamic>))
              .toList(),
        );

Map<String, dynamic> _$UserGeoLocationSearchNearbyResponseToJson(
        UserGeoLocationSearchNearbyResponse instance) =>
    <String, dynamic>{
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'total': instance.total,
      'list': instance.list?.map((e) => e.toJson()).toList(),
    };

UserLocationProjection _$UserLocationProjectionFromJson(
        Map<String, dynamic> json) =>
    UserLocationProjection(
      uid: json['uid'] as int?,
      nickname: json['nickname'] as String?,
      phone_number: json['phone_number'] as String?,
      avatar: json['avatar'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UserLocationProjectionToJson(
        UserLocationProjection instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'nickname': instance.nickname,
      'phone_number': instance.phone_number,
      'avatar': instance.avatar,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'distance': instance.distance,
    };
