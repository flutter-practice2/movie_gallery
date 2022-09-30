import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_gallery/Constants.dart';
import 'package:movie_gallery/http/MyClient.dart';
import 'package:movie_gallery/http/model/UserRegisterRequest.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../http/model/User.dart';
import '../inject/injection.dart';
import 'LoginNotifier.dart';

class LoginWidget extends StatefulWidget {
  @override
  State createState() {
    return new _LoginWidgetState();
  }
}

class _LoginWidgetState extends State<LoginWidget> {
  LoginNotifier loginNotifier = getIt<LoginNotifier>();

  TextEditingController nicknameController = TextEditingController();
  TextEditingController phone_numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          margin: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: nicknameController,
                decoration: InputDecoration(hintText: 'nickname'),
              ),

              SizedBox(
                height: 8,
              ),
              TextField(
                controller: phone_numberController,
                decoration: InputDecoration(hintText: 'phone number'),
              ),
              SizedBox(
                height: 16,
              ),
              TextButton(
                  onPressed: () async {
                    UserRegisterRequest request = UserRegisterRequest(
                        nickname: nicknameController.text,
                        phoneNumber: phone_numberController.text);

                    await loginNotifier.login(request);
                  },
                  child: Text('Login'))
            ],
          ),
        ),
      ),
    );
  }
}
