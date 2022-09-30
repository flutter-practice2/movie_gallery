
import 'package:injectable/injectable.dart';
import 'package:movie_gallery/Constants.dart';

import './dao/dao.dart';
import './entity/entity.dart';


@singleton
class ChatMessageRepository{
 final int perPage= Constants.DB_PER_PAGE;

  ChatMessageDao _chatMessageDao;

  ChatMessageRepository(this._chatMessageDao);

  Stream<List<ChatMessageEntity>> findByChatId(int chatId){
    return _chatMessageDao.findByChatId(chatId);
  }

  Future<List<ChatMessageEntity>> pageByChatId(int chatId,int offset,int rowCount){
    return _chatMessageDao.pageByChatId(chatId,offset,rowCount);
  }

  Future<void>insert(ChatMessageEntity entity){
    print('before_insert: $entity');
    return _chatMessageDao.insert(entity).then((value) {
      print('after_insert: $entity');
      entity.id=value;
      print('after_set_id: $entity');

    });

  }

  Future<List<ChatMessageEntity>> findNewItems(int chatId,int startId) {
    print('findNewItems,chatId:$chatId,startId:$startId');
    return _chatMessageDao.findNewItems(chatId,startId);
  }

}
