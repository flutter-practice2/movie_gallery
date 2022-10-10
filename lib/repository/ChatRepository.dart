import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:movie_gallery/repository/dao/dao.dart';
import 'package:movie_gallery/repository/entity/entity.dart';
import 'package:movie_gallery/repository/view/ChatView.dart';

@singleton
class ChatRepository {
  ChatDao chatDao;
  ChatMessageDao chatMessageDao;

  ChatRepository(this.chatDao, this.chatMessageDao);

  Future<List<ChatView>> findAll() {
    return chatDao.findAll();
  }

  Future<void> insert(ChatEntity entity) {
    return chatDao.insert(entity);
  }

  Future<void> delete(int id) async {
    await chatMessageDao.delete(id);
    return chatDao.delete(id);
  }
}
