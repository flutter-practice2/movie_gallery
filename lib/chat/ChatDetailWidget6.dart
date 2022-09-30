import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movie_gallery/Constants.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/login/LoginNotifier.dart';
import 'package:movie_gallery/repository/entity/entity.dart';
import 'package:movie_gallery/widget/Avatar.dart';

import '../mqtt/MyMqttClient.dart';
import '../repository/ChatMessageRepository.dart';
import '../repository/UserRepository.dart';
import 'ImeWidget6.dart';

/**
 * use indexOffset to compensate to stick page if not at bottom while new item inserted to db,
 * but have a bug:  if in viewport are all new items, it will not stick.
 *
 * compensation machanic: if index < indexOffset, use index = index + indexOffset
 */
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
      invisibleItemsThreshold: Constants.DB_PER_PAGE*2);

  int dbPagingOffset = 0;
  int indexOffset = 0;
  int dbLargeId = -1;

  MyMqttClient mqttClient = getIt<MyMqttClient>();
  late StreamSubscription subscription;

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
        int perPage = Constants.DB_PER_PAGE;
        List<ChatMessageEntity> entities = await chatMessageRepository
            .pageByChatId(peerId, dbPagingOffset, perPage);
        dbPagingOffset += entities.length;
        int newestId = entities.first.id!;
        if (newestId > this.dbLargeId) {
          this.dbLargeId = newestId;
        }

        if (entities.length < perPage) {
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
          this.prependFromDb();
        }
      });
    });
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
    return !loaded
        ? Container()
        : PagedListView<int, ChatMessageEntity>(
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) {
                //compensation scroll, keep the previous position
                var length = pagingController.itemList!.length;
                print(
                    'list_view_build_index,delta:$indexOffset,length:${length}: ${index},${item.message}');
                var nIndex = compensatedIndex(index, length);
                if (nIndex == -1) {
                  return Container();
                }
                item = pagingController.itemList![nIndex];
                return Container(
                  // height: height,
                  margin: EdgeInsets.only(top: 6),
                  child: buildTile(context, item),
                );
              },
              newPageProgressIndicatorBuilder: (context) {
                return CircularProgressIndicator();
              },
            ),
            reverse: true,
            shrinkWrap: true,
            scrollController: scrollController,
          );
  }

  void incrIndexOffset(int delta) {
    indexOffset += delta;
  }

  void incrDbPagingOffset() {
    dbPagingOffset++;
  }

  bool isAtBottom() {
    return scrollController.position.pixels ==
        scrollController.position.minScrollExtent;
  }

  int compensatedIndex(int index, int length) {
    if (this.isAtBottom()) {
      return index;
    }
    if (index < indexOffset) {
      //fix: indexOffset maybe large
      return index;
    }

    var nIndex = index + indexOffset;
    if (nIndex >= length) {
      return -1;
    }
    print('correct_position:previous:$index,delta:$indexOffset,after:$nIndex');
    return nIndex;
  }

  void prepend(List<ChatMessageEntity> entities) {
    bool atBottom =
        isAtBottom(); //should be before  pagingController.itemList = entities + previous;
    print('current_is_at_bottom:$atBottom');

    var previous = pagingController.itemList ?? [];
    incrIndexOffset(entities.length); //must before inserting to itemList
    pagingController.itemList = entities + previous;

    if (atBottom) {
      scrollToBottom();
    }
  }

  void prependFromDb() {
    if (dbLargeId < 0) return;
    chatMessageRepository
        .findNewItems(this.peerId, dbLargeId + 1)
        .then((List<ChatMessageEntity> items) {
      dbLargeId = items.last.id!;
      prepend(items);
    });
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
