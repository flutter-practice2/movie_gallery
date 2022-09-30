import 'package:cached_network_image/cached_network_image.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movie_gallery/repository/UserRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../http/MyClient.dart';
import '../http/model/export.dart';
import '../inject/injection.dart';
import 'FriendDetailWidget.dart';

class FriendListWidget extends StatefulWidget {
  @override
  State createState() {
    return _FriendListWidgetState();
  }
}

class _FriendListWidgetState extends State<FriendListWidget> {
  PagingController<int, User> pagingController =
      PagingController<int, User>(firstPageKey: Constants.DEFAULT_PAGE);

  UserRepository friendRepository = getIt<UserRepository>();
  SharedPreferences prefs = getIt<SharedPreferences>();

  @override
  void initState() {
    super.initState();
    int loginId = prefs.getInt(Constants.PREFS_LOGIN_ID)!;
    pagingController.addPageRequestListener(
      (pageKey) async {
        try {
          Response<FriendListResponse> response =
              await friendRepository.friendList(loginId, pageNumber: pageKey);
          //use repository
          if (response.isSuccessful) {
            var newItems = response.body?.list ?? [];
            if (newItems.length < Constants.PAGE_SIZE) {
              pagingController.appendLastPage(newItems);
            } else {
              pagingController.appendPage(newItems, pageKey + 1);
            }

          } else {
            print(response);
            this.pagingController.error(response);
          }
        } catch (e) {
          print(e);
          this.pagingController.error(e);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          pagingController.refresh();
        },
        child: PagedListView<int, User>(
          padding: EdgeInsets.all(8),
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<User>(
            itemBuilder: (context, item, index) {
              User user = item;
              return Container(
                padding: EdgeInsets.only(top: 8),
                child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FriendDetailWidget(user),));
                    },
                    child: buildItemWidget(user, context)),
              );
            },
          ),
        ),
      ),
    );
  }

  Row buildItemWidget(User user, BuildContext context) {
    return Row(
      children: [
        user.avatar == null || user.avatar!.isEmpty
            ? Container(
                width: 100,
                height: 100,
                child: Icon(Icons.person),
              )
            : CachedNetworkImage(
                imageUrl: user.avatar!,
                width: 100,
                height: 100,
              ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                user.nickname ?? '',
                style: Theme.of(context).textTheme.headline6,
              )),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    this.pagingController.dispose();
  }
}
