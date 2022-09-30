import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_gallery/http/MyClient.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/ImageUploadUtil.dart';
import '../http/model/export.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  DisplayPictureScreen(this.imagePath);

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  MyClient myClient = getIt<MyClient>();
  SharedPreferences prefs = getIt<SharedPreferences>();
  bool uploading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.file(File(widget.imagePath)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: uploading
                        ? CircularProgressIndicator()
                        : FloatingActionButton(
                            onPressed: () {
                              myClient.requestToken().then((response) async {
                                if (!response.isSuccessful ||
                                    response.body == null) {
                                  print('requestToken fail,$response');
                                  setState(() {
                                    uploading = false;
                                  });

                                  return;
                                }
                                print('requestToken success,$response');
                                RequestTokenResponse body = response.body!;
                                String imagePath = widget.imagePath;
                                await ImageUploadUtil.uploadImage(imagePath, body.putUrl!);
                                int loginId =
                                    prefs.getInt(Constants.PREFS_LOGIN_ID)!;

                                UserUpdateAvatarRequest request =
                                    UserUpdateAvatarRequest(
                                        uid: loginId, avatar: body.getUrl);
                                var resp = await myClient.updateAvatar(request);
                                if (resp.isSuccessful) {
                                  print('updateAvatar success');
                                  GoRouter.of(context).go('/?currentIndex=3');
                                  print('after_go_route_executed');
                                } else {
                                  print('updateAvatar fail,$resp');
                                  setState(() {
                                    uploading = false;
                                  });
                                }
                              });
                              setState(() {
                                uploading = true;
                              });
                            },
                            child: Icon(Icons.save_alt)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

