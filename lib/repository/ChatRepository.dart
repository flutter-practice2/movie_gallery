import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:movie_gallery/repository/dao/dao.dart';
import 'package:movie_gallery/repository/entity/entity.dart';
import 'package:movie_gallery/repository/view/ChatView.dart';

@singleton
class ChatRepository {
  ChatDao chatDao;

  ChatRepository(this.chatDao);


  Stream<List<ChatView>> findAll() {
    return chatDao.findAll();
  }

  Future<void> insert(ChatEntity entity) {
    return chatDao.insert(entity);
  }

  Future<void> delete(int id) {
    return chatDao.delete(id);

  }
}
