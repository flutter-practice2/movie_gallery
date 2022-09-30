class UserGeoLocationAddLocationRequest {
  int? uid;
  double? latitude;
  double? longitude;

  UserGeoLocationAddLocationRequest({
    this.uid,
    this.latitude,
    this.longitude,});

  UserGeoLocationAddLocationRequest.fromJson(dynamic json) {
    uid = json['uid'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  UserGeoLocationAddLocationRequest copyWith({ int? uid,
    double? latitude,
    double? longitude,
  }) =>
      UserGeoLocationAddLocationRequest(uid: uid ?? this.uid,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uid'] = uid;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    return map;
  }

}
