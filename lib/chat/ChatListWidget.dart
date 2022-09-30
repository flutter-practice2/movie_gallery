import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:movie_gallery/chat/ChatDetailWidget6.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/repository/ChatRepository.dart';

import '../repository/view/ChatView.dart';

class ChatListWidge extends StatefulWidget {
  @override
  State<ChatListWidge> createState() => _ChatListWidgeState();
}

class _ChatListWidgeState extends State<ChatListWidge> {
  ChatRepository chatRepository = getIt<ChatRepository>();
  late Stream<List<ChatView>> stream;

  @override
  void initState() {
    super.initState();

    stream = chatRepository.findAll();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          List<ChatView> items = snapshot.data!;
          return SafeArea(
              child: ListView.builder(
            itemBuilder: (context, index) {
              var item = items[index];
              return Slidable(
                endActionPane: ActionPane(
                  motion: DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        chatRepository.delete(item.id).then((value) {
                          setState(() {});
                        });
                      },
                      icon: Icons.delete,
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 8, left: 8),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                // ChatDetailWidget(item.id),
                            ChatDetailWidget(item.id),
                          ));
                    },
                    child: this.buildChatTile(item, context),
                  ),
                ),
              );
            },
            itemCount: items.length,
          ));
        }

        return Container();
      },
      stream: stream,
    );
  }

  Row buildChatTile(ChatView item, BuildContext context) {
    return Row(
      children: [
        item.avatar == null
            ? Container(
                width: 100,
                height: 100,
                child: Icon(Icons.person),
              )
            : CachedNetworkImage(
                imageUrl: item.avatar!,
                width: 100,
                height: 100,
              ),
        SizedBox(
          width: 8,
        ),
        Text(
          item.nickname ?? '',
          style: Theme.of(context).textTheme.headline6,
        )
      ],
    );
  }
}
