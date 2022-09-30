import 'package:floor/floor.dart';
import 'package:injectable/injectable.dart';
import '../db/AppDatabase.dart';
import '../entity/entity.dart';
import '../view/ChatView.dart';

@dao
@singleton
abstract class ChatDao {

  @factoryMethod
  static ChatDao chatDao(AppDatabase db) {
    return db.chatDao;
  }

  @Query('select * from chat_view')
  Stream<List<ChatView>> findAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(ChatEntity entity);

  @Query('delete from chat where id=:id')
  Future<void> delete(int id);
}
