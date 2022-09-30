import 'dart:core';

import 'package:json_annotation/json_annotation.dart';

part 'UserGeoLocationSearchNearbyResponse.g.dart';

@JsonSerializable(explicitToJson: true)
class UserGeoLocationSearchNearbyResponse {
  int? pageNumber;
  int? pageSize;
  int? total;
  List<UserLocationProjection>? list;

  UserGeoLocationSearchNearbyResponse({
    this.pageNumber,
    this.pageSize,
    this.total,
    this.list,
  });

  factory UserGeoLocationSearchNearbyResponse.fromJson(
          Map<String, dynamic> json) =>
      _$UserGeoLocationSearchNearbyResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UserGeoLocationSearchNearbyResponseToJson(this);


  @override
  String toString() {
    return '{pageNumber: $pageNumber, pageSize: $pageSize, total: $total, list: $list}';
  }
}

@JsonSerializable(explicitToJson: true)
class UserLocationProjection {
  int? uid;
  String? nickname;
  String? phone_number;
  String? avatar;
  double? latitude;
  double? longitude;
  double? distance;

  UserLocationProjection({
    this.uid,
    this.nickname,
    this.phone_number,
    this.avatar,
    this.latitude,
    this.longitude,
    this.distance,
  });

  factory UserLocationProjection.fromJson(Map<String, dynamic> json) =>
      _$UserLocationProjectionFromJson(json);

  Map<String, dynamic> toJson() => _$UserLocationProjectionToJson(this);

  @override
  String toString() {
    return '{uid: $uid, nickname: $nickname, phone_number: $phone_number, avatar: $avatar, latitude: $latitude, longitude: $longitude, distance: $distance}';
  }


}
