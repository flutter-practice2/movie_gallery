import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:movie_gallery/http/MyClient.dart';
import 'package:movie_gallery/http/model/export.dart';
import 'package:movie_gallery/repository/dao/UserDao.dart';
import 'package:movie_gallery/repository/entity/entity.dart';

@singleton
class UserRepository {
  MyClient myClient;
  UserDao userDao;

  UserRepository(this.myClient, this.userDao);

  Future<Response<FriendListResponse>> friendList(int uid,
      {int pageNumber: Constants.DEFAULT_PAGE,
      int pageSize: Constants.PAGE_SIZE}) async {
    //fixme: should use local db as single source of truth, prevent from double io everytime
    Response<FriendListResponse> response = await myClient.friendList(uid,
        pageNumber: pageNumber, pageSize: pageSize);

    if (response.isSuccessful) {
      List<User> list = response.body?.list ?? [];
      var entities = list
          .map((e) =>
              UserEntity(uid: e.uid!, avatar: e.avatar, nickname: e.nickname))
          .toList();

      if (entities.isNotEmpty) {
        await userDao.insertAll(entities);
      }
    }

    return response;
  }

  Future<Response> friendAdd(int loginId, UserLocationProjection item) async {
    UserEntity entity = UserEntity(
        uid: item.uid!, nickname: item.nickname, avatar: item.avatar);
    await userDao.insert(entity);

    FriendsAddRequest request =
        FriendsAddRequest(uid: loginId, friend_uid: item.uid!);
    Response response = await myClient.friendAdd(request);

    return response;
  }

  Future<UserEntity?> findById(int id){
    return userDao.findById(id);
  }
}
