import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movie_gallery/chat/ChatDetailWidget6.dart';
import 'package:movie_gallery/http/model/export.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/repository/ChatRepository.dart';

import '../repository/view/ChatView.dart';

class ChatListWidge extends StatefulWidget {
  @override
  State<ChatListWidge> createState() => _ChatListWidgeState();
}

class _ChatListWidgeState extends State<ChatListWidge> {
  ChatRepository chatRepository = getIt<ChatRepository>();
  PagingController<int, ChatView> pagingController =
      PagingController(firstPageKey: Constants.DB_START_PAGE);

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener((pageKey) async {
      List<ChatView> page = await chatRepository.findAll();
      pagingController.appendLastPage(page);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          pagingController.refresh();
        },
        child: buildPage(),
      ),
    );
  }

  PagedListView<int, ChatView> buildPage() {
    return PagedListView(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate<ChatView>(
        itemBuilder: (context, item, index) {
          return buildSlidableTile(item, context);
        },
      ),
    );
  }

  Slidable buildSlidableTile(ChatView item, BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              chatRepository.delete(item.id).then((value) {
                setState(() {
                  pagingController.itemList!.remove(item);
                });
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
