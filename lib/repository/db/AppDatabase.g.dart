// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ChatDao? _chatDaoInstance;

  ChatMessageDao? _chatMessageDaoInstance;

  UserDao? _userDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `chat_message` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `chatId` INTEGER NOT NULL, `uid` INTEGER NOT NULL, `message` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `chat` (`id` INTEGER NOT NULL, `unread` INTEGER, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `user` (`uid` INTEGER NOT NULL, `nickname` TEXT, `avatar` TEXT, PRIMARY KEY (`uid`))');
        await database.execute(
            'CREATE INDEX `index_chat_message_chatId_id` ON `chat_message` (`chatId`, `id`)');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `chat_view` AS select c.id,c.unread,u.nickname,u.avatar  from chat c inner join user u on c.id=u.uid');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ChatDao get chatDao {
    return _chatDaoInstance ??= _$ChatDao(database, changeListener);
  }

  @override
  ChatMessageDao get chatMessageDao {
    return _chatMessageDaoInstance ??=
        _$ChatMessageDao(database, changeListener);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }
}

class _$ChatDao extends ChatDao {
  _$ChatDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _chatEntityInsertionAdapter = InsertionAdapter(
            database,
            'chat',
            (ChatEntity item) =>
                <String, Object?>{'id': item.id, 'unread': item.unread});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ChatEntity> _chatEntityInsertionAdapter;

  @override
  Future<List<ChatView>> findAll() async {
    return _queryAdapter.queryList('select * from chat_view',
        mapper: (Map<String, Object?> row) => ChatView(
            id: row['id'] as int,
            unread: row['unread'] as int?,
            nickname: row['nickname'] as String?,
            avatar: row['avatar'] as String?));
  }

  @override
  Future<void> delete(int id) async {
    await _queryAdapter
        .queryNoReturn('delete from chat where id=?1', arguments: [id]);
  }

  @override
  Future<void> insert(ChatEntity entity) async {
    await _chatEntityInsertionAdapter.insert(
        entity, OnConflictStrategy.replace);
  }
}

class _$ChatMessageDao extends ChatMessageDao {
  _$ChatMessageDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _chatMessageEntityInsertionAdapter = InsertionAdapter(
            database,
            'chat_message',
            (ChatMessageEntity item) => <String, Object?>{
                  'id': item.id,
                  'chatId': item.chatId,
                  'uid': item.uid,
                  'message': item.message
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ChatMessageEntity> _chatMessageEntityInsertionAdapter;

  @override
  Stream<List<ChatMessageEntity>> findByChatId(int chatId) {
    return _queryAdapter.queryListStream(
        'select * from chat_message where chatId=?1 order by id desc',
        mapper: (Map<String, Object?> row) => ChatMessageEntity(
            id: row['id'] as int?,
            chatId: row['chatId'] as int,
            uid: row['uid'] as int,
            message: row['message'] as String),
        arguments: [chatId],
        queryableName: 'chat_message',
        isView: false);
  }

  @override
  Future<List<ChatMessageEntity>> pageByChatId(
      int chatId, int offset, int rowCount) async {
    return _queryAdapter.queryList(
        'select * from chat_message where chatId=?1 order by id desc limit ?2,?3',
        mapper: (Map<String, Object?> row) => ChatMessageEntity(id: row['id'] as int?, chatId: row['chatId'] as int, uid: row['uid'] as int, message: row['message'] as String),
        arguments: [chatId, offset, rowCount]);
  }

  @override
  Future<List<ChatMessageEntity>> findNewItems(int chatId, int startId) async {
    return _queryAdapter.queryList(
        'select * from chat_message where chatId=?1 and id>=?2',
        mapper: (Map<String, Object?> row) => ChatMessageEntity(
            id: row['id'] as int?,
            chatId: row['chatId'] as int,
            uid: row['uid'] as int,
            message: row['message'] as String),
        arguments: [chatId, startId]);
  }

  @override
  Future<void> delete(int chatId) async {
    await _queryAdapter.queryNoReturn(
        'delete from chat_message where chatId=?1',
        arguments: [chatId]);
  }

  @override
  Future<int> insert(ChatMessageEntity entity) {
    return _chatMessageEntityInsertionAdapter.insertAndReturnId(
        entity, OnConflictStrategy.abort);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _userEntityInsertionAdapter = InsertionAdapter(
            database,
            'user',
            (UserEntity item) => <String, Object?>{
                  'uid': item.uid,
                  'nickname': item.nickname,
                  'avatar': item.avatar
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UserEntity> _userEntityInsertionAdapter;

  @override
  Future<UserEntity?> findById(int uid) async {
    return _queryAdapter.query('select * from user where uid=?1',
        mapper: (Map<String, Object?> row) => UserEntity(
            uid: row['uid'] as int,
            nickname: row['nickname'] as String?,
            avatar: row['avatar'] as String?),
        arguments: [uid]);
  }

  @override
  Future<List<int>> insertAll(List<UserEntity> entities) {
    return _userEntityInsertionAdapter.insertListAndReturnIds(
        entities, OnConflictStrategy.replace);
  }

  @override
  Future<int> insert(UserEntity entity) {
    return _userEntityInsertionAdapter.insertAndReturnId(
        entity, OnConflictStrategy.abort);
  }
}
