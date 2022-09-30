import 'package:floor/floor.dart';
import 'package:injectable/injectable.dart';
import '../db/AppDatabase.dart';
import '../entity/entity.dart';

@singleton
@dao
abstract class ChatMessageDao {
  @factoryMethod
  static ChatMessageDao chatMessageDao(AppDatabase db) {
    return db.chatMessageDao;
  }

  @Query('select * from chat_message where chatId=:chatId order by id desc')
  Stream<List<ChatMessageEntity>> findByChatId(int chatId);
  @Query('select * from chat_message where chatId=:chatId order by id desc limit :offset,:rowCount')
  Future<List<ChatMessageEntity>> pageByChatId(int chatId,int offset,int rowCount);//offset: 0-based

  @Insert()
  Future<int> insert(ChatMessageEntity entity);

  @Query('select * from chat_message where chatId=:chatId and id>=:startId ')
  Future<List<ChatMessageEntity>> findNewItems(int chatId,int startId) ;

}
