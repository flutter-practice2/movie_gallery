import 'package:floor/floor.dart';
import 'package:injectable/injectable.dart';
import 'package:movie_gallery/repository/view/ChatView.dart';
import '../entity/entity.dart';
import '../dao/dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';

part 'AppDatabase.g.dart';

@Database(version: 1, entities: [ChatMessageEntity, ChatEntity, UserEntity]
,views: [ChatView])
abstract class AppDatabase extends FloorDatabase {

  ChatDao get chatDao;

  ChatMessageDao get chatMessageDao;

  UserDao get userDao;
}
