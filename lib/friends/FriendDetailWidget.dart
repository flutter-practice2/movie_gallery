import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/repository/entity/ChatEntity.dart';

import '../chat/ChatDetailWidget.dart';
import '../http/model/export.dart';
import '../repository/ChatRepository.dart';

class FriendDetailWidget extends StatelessWidget {
  final User item;
  ChatRepository chatRepository = getIt<ChatRepository>();

  FriendDetailWidget(this.item);

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context);
    var size = query.size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                item.avatar != null && item.avatar!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.avatar ?? '',
                        width: size.width,
                        height: size.height / 2,
                      )
                    : Container(
                        width: size.width,
                        height: size.height / 2,
                        child: Icon(Icons.person),
                      ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item.nickname ?? '',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        item.uid?.toString() ?? '',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        item.phone_number ?? '',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Container(
                        width: double.infinity,
                        height: 38,
                        child: TextButton(
                          onPressed: () async {
                            ChatEntity entity = ChatEntity(id: item.uid!);
                            await chatRepository.insert(entity);
                            print('add_chat_entity, $entity');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatDetailWidget(item.uid!),
                                ));
                          },
                          child: Text('chat'),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
