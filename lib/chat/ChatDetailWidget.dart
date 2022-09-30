import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/login/LoginNotifier.dart';
import 'package:movie_gallery/repository/entity/entity.dart';
import 'package:movie_gallery/widget/Avatar.dart';

import '../repository/ChatMessageRepository.dart';
import '../repository/UserRepository.dart';
import 'ImeWidget.dart';

/**
 * use StreamBuilder. the persistence library floor do not support single item emition
 */
class ChatDetailWidget extends StatefulWidget {
  late int peerId;

  ChatDetailWidget(this.peerId);

  @override
  State<ChatDetailWidget> createState() => _ChatDetailWidgetState();
}

class _ChatDetailWidgetState extends State<ChatDetailWidget> {
  late int loginId;
  late int peerId;
  UserRepository userRepository = getIt<UserRepository>();
  ChatMessageRepository chatMessageRepository = getIt<ChatMessageRepository>();

  bool loaded = false;
  late UserEntity peerUser;
  late UserEntity loginUser;
  late Stream<List<ChatMessageEntity>> stream;
  ScrollController scrollController = ScrollController();

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
            ImeWidget(loginId, peerId),
          ],
        ),
      ),
    );
  }

  Widget buildMessageListRegion() {
    return !loaded
        ? Container()
        : StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                List<ChatMessageEntity> items = snapshot.data ?? [];
                print('one_stream_items_count:${items.length}');
                return ListView.builder(
                  itemBuilder: (context, index) {
                    var item = items[index];
                    print('list_view_build_index:${index},${item.message}');
                    return Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: buildTile(context, item),
                    );
                  },
                  itemCount: items.length,
                  // controller: scrollController,
                  shrinkWrap: true,
                  reverse: true,
                );
              }

              return Container();
            },
          );
  }

  void scrollToBottom() {
    print('scroll_to_bottom');
    if(scrollController.positions.isEmpty) {
      print('scroll_position_is_empty');
      return;
    }

    if(scrollController.position.pixels==scrollController.position.maxScrollExtent) {
      print('current_is_at_bottom');
    }
    // scrollController.animateTo(scrollController.position.maxScrollExtent,
    //     duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);

    scrollController.jumpTo(scrollController.position.maxScrollExtent);


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
            child: Text(item.message),
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
