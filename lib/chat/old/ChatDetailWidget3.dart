import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movie_gallery/Constants.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/login/LoginNotifier.dart';
import 'package:movie_gallery/repository/entity/entity.dart';
import 'package:movie_gallery/widget/Avatar.dart';

import '../../repository/ChatMessageRepository.dart';
import '../../repository/UserRepository.dart';
import 'ImeWidget3.dart';

class ChatDetailWidget extends StatefulWidget {
  late int peerId;

  ChatDetailWidget(this.peerId);

  @override
  State<ChatDetailWidget> createState() =>
      ChatDetailWidgetState(peerId: peerId);
}

class ChatDetailWidgetState extends State<ChatDetailWidget> {
  late final int loginId;
  final int peerId;
  UserRepository userRepository = getIt<UserRepository>();
  ChatMessageRepository chatMessageRepository = getIt<ChatMessageRepository>();

  bool loaded = false;
  late UserEntity peerUser;
  late UserEntity loginUser;
  ScrollController scrollController = ScrollController();

  PagingController<int, ChatMessageEntity> pagingController =
      PagingController(firstPageKey: Constants.DB_START_PAGE);

  int dbPagingOffset = 0;

  ChatDetailWidgetState({
    required this.peerId,
  }) {
    LoginNotifier changeNotifier = getIt<LoginNotifier>();
    loginId = changeNotifier.loginId!;
  }

  @override
  void initState() {
    super.initState();

    userRepository.findById(peerId).then((value) => peerUser = value!);
    userRepository
        .findById(loginId)
        .then((value) => loginUser = value!)
        .then((value) {})
        .then((value) {

      pagingController.addPageRequestListener((pageKey) async {
        int perPage = Constants.DB_PER_PAGE;
        List<ChatMessageEntity> entities = await chatMessageRepository
            .pageByChatId(peerId, dbPagingOffset, perPage);
        dbPagingOffset += entities.length;
        if (entities.length < perPage) {
          pagingController.appendLastPage(entities);
        } else {
          pagingController.appendPage(entities, pageKey + 1);
        }
      });

      setState(() {
        loaded = true;
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
                print(
                    'list_view_build_index,length:${pagingController.itemList!.length}: ${index},${item.message}');

                return Container(
                  // height: height,
                  margin: EdgeInsets.only(top:6),
                  child: buildTile(context, item),
                );
              },
            ),
            reverse: true,
            shrinkWrap: true,
            scrollController: scrollController,
          );
  }

  void incrOffset() {
    dbPagingOffset++;
  }


  bool isAtBottom() {
    return scrollController.position.pixels ==
        scrollController.position.minScrollExtent;
  }

  void refresh() {
    print('message_list_refreshed');
    dbPagingOffset = 0;
    this.pagingController.refresh();
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
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Avatar(peerUser.avatar, 50, 50),
          SizedBox(
            width: 5,
          ),
          Padding(
              padding: EdgeInsets.only(right: 50), child: Text(item.message))
        ],
      );
    } else {
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
                child: Text(item.message)), //todo
          ),
          SizedBox(
            width: 5,
          ),
          Avatar(peerUser.avatar, 50, 50),
        ],
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }
}
