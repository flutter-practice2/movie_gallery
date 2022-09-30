import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_gallery/http/MyClient.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../http/model/export.dart';
import 'TakePictureScreen.dart';

class MyselfWidget extends StatefulWidget {

  @override
  State<MyselfWidget> createState() => _MyselfWidgetState();


}

class _MyselfWidgetState extends State<MyselfWidget> {
  MyClient myClient = getIt<MyClient>();
  SharedPreferences prefs = getIt<SharedPreferences>();
  late int loginId;

  bool loaded = false;
  late UserGetDetailResponse detail;

  @override
  void initState() {
    super.initState();
    loginId = prefs.getInt(Constants.PREFS_LOGIN_ID)!;
    myClient.getDetail(loginId).then((response) {
      UserGetDetailResponse? detail = response.body;
      if (detail != null) {
        setState(() {
          loaded = true;
          this.detail = detail;
        },);

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var size = mediaQuery.size;

    return SafeArea(
      child: Scaffold(
        body: !loaded
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  detail.avatar != null && detail.avatar!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: detail.avatar!,
                          width: size.width,
                          height: size.height / 2,
                        )
                      : Container(
                          width: size.width,
                          height: size.height / 2,
                          child: Icon(Icons.person),

                        ),
                  Padding(padding: EdgeInsets.all(8),
                  child: 
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(detail.nickname??'',style:Theme.of(context).textTheme.headline5,),
                        SizedBox(height: 8,),
                        Text(detail.uid.toString(),style: Theme.of(context).textTheme.bodyText2,),
                        SizedBox(height: 8,),
                        Text(detail.phoneNumber??'',style: Theme.of(context).textTheme.bodyText1,),

                      ],
                    ),),
                  SizedBox(height: 16,),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: FloatingActionButton(onPressed: () async {
                      GoRouter.of(context).go('/TakePictureScreen');
                    },
                      child: Icon(Icons.camera_alt,),
                    ),

                  )
              
                ],
              ),
      ),
    );
  }
}
