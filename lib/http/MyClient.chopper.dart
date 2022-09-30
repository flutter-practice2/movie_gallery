// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MyClient.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$MyClient extends MyClient {
  _$MyClient([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = MyClient;

  @override
  Future<Response<UserGeoLocationSearchNearbyResponse>> searchNearby(
      double latitude, double longitude,
      [int pageNumber = Constants.DEFAULT_PAGE,
      int pageSize = Constants.PAGE_SIZE]) {
    final $url = '/UserGeoLocation/searchNearby';
    final $params = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'pageNumber': pageNumber,
      'pageSize': pageSize
    };
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<UserGeoLocationSearchNearbyResponse,
        UserGeoLocationSearchNearbyResponse>($request);
  }

  @override
  Future<Response<User>> register(UserRegisterRequest request) {
    final $url = '/User/register';
    final $body = request;
    final $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<User, User>($request);
  }

  @override
  Future<Response<bool>> addLocation(
      UserGeoLocationAddLocationRequest request) {
    final $url = '/UserGeoLocation/addLocation';
    final $body = request;
    final $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<bool, bool>($request);
  }

  @override
  Future<Response<UserGetDetailResponse>> getDetail(int uid) {
    final $url = '/User/getDetail';
    final $params = <String, dynamic>{'uid': uid};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<UserGetDetailResponse, UserGetDetailResponse>($request);
  }

  @override
  Future<Response<RequestTokenResponse>> requestToken() {
    final $url = '/OssAcl/requestToken';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<RequestTokenResponse, RequestTokenResponse>($request);
  }

  @override
  Future<Response<dynamic>> updateAvatar(UserUpdateAvatarRequest request) {
    final $url = '/User/updateAvatar';
    final $body = request;
    final $request = Request('PATCH', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<FriendListResponse>> friendList(int uid,
      {int pageNumber = Constants.DEFAULT_PAGE,
      int pageSize = Constants.PAGE_SIZE}) {
    final $url = '/Friends/list';
    final $params = <String, dynamic>{
      'uid': uid,
      'pageNumber': pageNumber,
      'pageSize': pageSize
    };
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<FriendListResponse, FriendListResponse>($request);
  }

  @override
  Future<Response<dynamic>> friendAdd(FriendsAddRequest request) {
    final $url = '/Friends/add';
    final $body = request;
    final $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<bool>> isFriend(int selfUid, int uid) {
    final $url = '/Friends/isFriend';
    final $params = <String, dynamic>{'selfUid': selfUid, 'uid': uid};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<bool, bool>($request);
  }
}
