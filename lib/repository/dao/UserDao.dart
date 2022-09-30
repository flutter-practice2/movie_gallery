import 'package:floor/floor.dart';
import 'package:injectable/injectable.dart';

import '../db/AppDatabase.dart';
import '../entity/entity.dart';

@dao
@singleton
abstract class UserDao {
  @factoryMethod
  static UserDao userDao(AppDatabase db) {
    return db.userDao;
  }

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertAll(List<UserEntity> entities);

  @Insert()
  Future<int> insert(UserEntity entity);

  @Query('select * from user where uid=:uid')
  Future<UserEntity?> findById(int uid);

}
