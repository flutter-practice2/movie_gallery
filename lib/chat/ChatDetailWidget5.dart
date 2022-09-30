import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movie_gallery/Constants.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/login/LoginNotifier.dart';
import 'package:movie_gallery/repository/entity/entity.dart';
import 'package:movie_gallery/widget/Avatar.dart';
import 'package:paging_view/paging_view.dart';

import '../mqtt/MyMqttClient.dart';
import '../repository/ChatMessageRepository.dart';
import '../repository/UserRepository.dart';
import 'ImeWidget5.dart';

class ChatDetailWidget extends StatefulWidget {
  late int peerId;

  ChatDetailWidget(this.peerId);

  @override
  State<ChatDetailWidget> createState() => ChatDetailWidgetState();
}

class ChatDetailWidgetState extends State<ChatDetailWidget> {
  late int loginId;
  late int peerId;
  UserRepository userRepository = getIt<UserRepository>();
  ChatMessageRepository chatMessageRepository = getIt<ChatMessageRepository>();

  bool loaded = false;
  late UserEntity peerUser;
  late UserEntity loginUser;
  late Stream<List<ChatMessageEntity>> stream;
  ScrollController scrollController = ScrollController();

  PagingController<int, ChatMessageEntity> pagingController = PagingController(
      firstPageKey: Constants.DB_START_PAGE,
      invisibleItemsThreshold: Constants.DB_PER_PAGE);

  int dbPagingOffset = 0;
  int dbLargeId = -1;
  int indexOffset = 0;//useless for this paging impl

  MyMqttClient mqttClient = getIt<MyMqttClient>();
  late StreamSubscription subscription;

  late PagingDataSource dataSource;

  @override
  void initState() {
    super.initState();
    peerId = widget.peerId;

    LoginNotifier changeNotifier = getIt<LoginNotifier>();
    loginId = changeNotifier.loginId!;

    userRepository.findById(peerId).then((value) => peerUser = value!);
    userRepository
        .findById(loginId)
        .then((value) => loginUser = value!)
        .then((value) {
      stream = chatMessageRepository.findByChatId(peerId);

      pagingController.addPageRequestListener((pageKey) async {
        List<ChatMessageEntity> entities = await fetchPage();

        if (entities.length < Constants.DB_PER_PAGE) {
          pagingController.appendLastPage(entities);
        } else {
          pagingController.appendPage(entities, pageKey + 1);
        }
      });

      setState(() {
        loaded = true;
      });

      subscription =
          mqttClient.streamController.stream.listen((ChatMessageEntity entity) {
        if (entity.uid == this.peerId) {
          this.incrDbPagingOffset();
          this.prependFromDb2();
        }
      });
    });
    dataSource = PagingDataSource(this);
    scrollController.addListener(() {
      print('scrollController_scrolled');
      resetIndexOffset();

    });
  }


  Future<List<ChatMessageEntity>> fetchPage() async {
    List<ChatMessageEntity> entities = await chatMessageRepository.pageByChatId(
        peerId, dbPagingOffset, Constants.DB_PER_PAGE);
    dbPagingOffset += entities.length;
    int newestId = entities.first.id!;
    if (newestId > this.dbLargeId) {
      this.dbLargeId = newestId;
    }
    return entities;
  }

  @override
  Widget build(BuildContext context) {
    print('re_build');

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 38,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(child: buildMessageListRegion()),
            ImeWidget(this),
          ],
        ),
      ),
    );
  }

  Widget buildMessageListRegion() {
    return !loaded ? Container() : buildPagedListView2();
  }

  Widget buildPagedListView2() {
    return PagingList<int, ChatMessageEntity>(
      dataSource: dataSource,
      builder: (context, item, index) {
        print(
            'list_view_build_index,: ${index},${item.message}');
        return Container(
          margin: EdgeInsets.only(top: 6),
          child: buildTile(context, item),
        );
      },
      errorBuilder: (context, e) {
        return Center(
          child: Text('$e'),
        );
      },
      initialLoadingWidget: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      appendLoadingWidget: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      emptyWidget: const Center(
        child: Text('No Item'),
      ),
      reverse: true,
      shrinkWrap: true,
      controller: scrollController,
    );
  }

  void incrDbPagingOffset() {
    dbPagingOffset++;
  }
  void incrIndexOffset(int delta) {
    indexOffset += delta;
  }
  void resetIndexOffset(){
    indexOffset=0;
  }
  int compensatedIndex(int index){
    return index+indexOffset;
  }

  bool isAtBottom() {
    if(!scrollController.hasClients) {
      return false;
    }
    return scrollController.position.pixels ==
        scrollController.position.minScrollExtent;
  }

  void tryScrollToBottom() {
    bool atBottom =
        isAtBottom(); //should be before  pagingController.itemList = entities + previous;
    print('current_is_at_bottom:$atBottom');

    if (atBottom) {
      scrollToBottom();
    }
  }

  void prependFromDb2() async {
    await dataSource.prepend();
    tryScrollToBottom();
  }

  Future<List<ChatMessageEntity>> loadNewItems() async {
    if (dbLargeId < 0) return [];
    List<ChatMessageEntity> items =
        await chatMessageRepository.findNewItems(this.peerId, dbLargeId + 1);
    if (items.isEmpty) {
      return [];
    }
    dbLargeId = items.last.id!;
    print('loadNewItems:${items.length}');

    return items;
  }

  void scrollToBottom() {
    print('scroll_to_bottom');
    if (!scrollController.hasClients) {
      print('scroll_position_is_empty');
      return;
    }
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
  }

  Widget buildTile(BuildContext context, ChatMessageEntity item) {
    if (item.uid == peerId) {
      //peer
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Avatar(peerUser.avatar, 50, 50),
          SizedBox(
            width: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 50),
            child: Container(
                constraints: BoxConstraints(maxWidth: 250),
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: Text(item.message)),
          ),
        ],
      );
    } else {
      //me
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Container(
                constraints: BoxConstraints(maxWidth: 250),
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: Colors.lightGreenAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Text(item.message)),
          ),
          SizedBox(
            width: 5,
          ),
          Avatar(loginUser.avatar, 50, 50),
        ],
      );
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    scrollController.dispose();

    super.dispose();
  }
}

class PagingDataSource extends DataSource<int, ChatMessageEntity> {
  ChatDetailWidgetState _state;

  PagingDataSource(this._state);

  @override
  Future<LoadResult<int, ChatMessageEntity>> load(LoadParams<int> params) {
    return params.when(
      refresh: () async {
        List<ChatMessageEntity> entities = await _state.fetchPage();
        return LoadResult.success(
            page: PageData(
          data: entities,
          appendKey: 2,
        ));
      },
      prepend: (key) async {
        print('prepend_page_key:$key');
        List<ChatMessageEntity> items = await _state.loadNewItems();
        // if(items.isEmpty) {
        //   return LoadResult.none();
        // }
        _state.incrIndexOffset(items.length);
        return LoadResult.success(
            page: PageData(data: items, prependKey: null));
      },
      append: (key) async {
        print('append_page_key:$key');
        List<ChatMessageEntity> entities = await _state.fetchPage();
        return LoadResult.success(
            page: PageData(
          data: entities,
          appendKey: entities.isEmpty?null: key + 1,
        ));
      },
    );
  }

  Future<void> prepend() async {
    if (notifier.isLoading) {
      /// already loading
      return;
    }

    var key = notifier.prependPageKey;
    if (key == null) {
      /// no more prepend data
      key = 0;
    }

    final result = await load(
      LoadParams.prepend(
        key: key,
      ),
    );
    result.when(
      success: (page) => notifier.prepend(page),
      failure: (e) => notifier.setError(e),
      none: () => notifier.prepend(null),
    );
  }
}
