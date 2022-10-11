import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:movie_gallery/AppEnvironment.dart';
import 'package:movie_gallery/http/model/export.dart';

import 'converter.dart';
import 'model/UserRegisterRequest.dart';

part 'MyClient.chopper.dart';

@singleton
@ChopperApi()
abstract class MyClient extends ChopperService {
  @factoryMethod
  static MyClient create() {
    ChopperClient chopperClient = new ChopperClient(
        baseUrl: AppEnvironment.apiBaseUrl,
        interceptors: [HttpLoggingInterceptor()],
        // converter: MyConverter(),
        converter: converter,
        errorConverter: JsonConverter(),
        services: [_$MyClient()]);
    return _$MyClient(chopperClient);
  }

  @Get(path: '/UserGeoLocation/searchNearby')
  Future<Response<UserGeoLocationSearchNearbyResponse>> searchNearby(
      @Query() double latitude, @Query() double longitude,
      [@Query() int pageNumber = Constants.DEFAULT_PAGE,
      @Query() int pageSize = Constants.PAGE_SIZE]);

  @Put(path: '/User/register')
  Future<Response<User>> register(@Body() UserRegisterRequest request);

  @Put(path: '/UserGeoLocation/addLocation')
  Future<Response<bool>> addLocation(
      @Body() UserGeoLocationAddLocationRequest request);

  @Get(path: '/User/getDetail')
  Future<Response<UserGetDetailResponse>> getDetail(@Query() int uid);

  @Get(path: '/OssAcl/requestToken')
  Future<Response<RequestTokenResponse>> requestToken();

  @Patch(path: '/User/updateAvatar')
  Future<Response> updateAvatar(@Body() UserUpdateAvatarRequest request);

  @Get(path: '/Friends/list')
  Future<Response<FriendListResponse>> friendList(@Query() int uid,
      {@Query() int pageNumber: Constants.DEFAULT_PAGE,
      @Query() int pageSize: Constants.PAGE_SIZE});

  @Put(path: '/Friends/add')
  Future<Response> friendAdd(@Body() FriendsAddRequest request);

  @Get(path: '/Friends/isFriend')
  Future<Response<bool>> isFriend(@Query() int selfUid, @Query() int uid);

  @Post(path:'/errorReport/post')
  Future<Response> errorReportPost(@Body() ErrorReportPostRequest request);
}

void main() async {
  MyClient client = MyClient.create();

  var response = await client.searchNearby(10, 15);
  print(response.body.toString());
}
