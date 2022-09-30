import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_gallery/inject/injection.dart';

import '../http/MyClient.dart';
import '../http/model/export.dart';
import '../login/LoginNotifier.dart';
import '../repository/UserRepository.dart';

class NearbyDetailWidget extends StatefulWidget {
  final UserLocationProjection item;

  NearbyDetailWidget(this.item);

  @override
  State<NearbyDetailWidget> createState() => _NearbyDetailWidgetState();
}

class _NearbyDetailWidgetState extends State<NearbyDetailWidget> {
  MyClient myClient = getIt<MyClient>();
  UserRepository friendRepository = getIt<UserRepository>();
  bool isFriend = true;
  late int loginId;
  LoginNotifier loginNotifier=getIt<LoginNotifier>();

  @override
  void initState() {
    super.initState();
    loginId = loginNotifier.loginId!;
    myClient.isFriend(loginId, widget.item.uid!).then((value) {
     setState((){
       isFriend = value.body ?? false;

     });

    }).onError((error, stackTrace) {
      print('$error,$stackTrace');
    });
  }

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
                widget.item.avatar != null && widget.item.avatar!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.item.avatar ?? '',
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
                                widget.item.nickname ?? '',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  widget.item.distance != null
                                      ? (widget.item.distance! / 1000)
                                              .toStringAsFixed(2) +
                                          ' km'
                                      : '',
                                  style: Theme.of(context).textTheme.bodyText1,
                                )),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        widget.item.uid?.toString() ?? '',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        widget.item.phone_number ?? '',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      isFriend
                          ? SizedBox.shrink()
                          : Container(
                              padding: EdgeInsets.only(top: 16),
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await friendRepository.friendAdd(loginId,widget.item);
                                    print('add_friend success');
                                    setState(() {
                                      isFriend=true;
                                    });
                                  } catch (e) {
                                    print('add_friend fail: $e');
                                  }

                                },
                                child: Text('add friend'),
                              ))
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
