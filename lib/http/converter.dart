import './model/export.dart';
import 'JsonSerializableConverter.dart';

var converter = JsonSerializableConverter({
  UserGeoLocationSearchNearbyResponse:
      UserGeoLocationSearchNearbyResponse.fromJson,
  User: User.fromJson,
  UserGetDetailResponse: UserGetDetailResponse.fromJson,
  RequestTokenResponse: RequestTokenResponse.fromJson,
  FriendListResponse: FriendListResponse.fromJson,
});
