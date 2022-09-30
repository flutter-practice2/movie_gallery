import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants.dart';
import '../http/MyClient.dart';
import '../http/model/User.dart';
import '../http/model/UserRegisterRequest.dart';
import '../inject/injection.dart';
import '../http/model/export.dart';
import '../mqtt/MyMqttClient.dart';

@singleton
class LoginNotifier extends ChangeNotifier {
  SharedPreferences prefs;

  MyClient myClient;
  MyMqttClient mqttClient;

  late int _loginId;

  LoginNotifier(this.prefs, this.myClient,this.mqttClient);

  Future login(UserRegisterRequest request) async {
    var response = await myClient.register(request);
    User? user = response.body;
    if (user != null) {
      prefs.setInt(Constants.PREFS_LOGIN_ID, user.uid!);
      _loginId = user.uid!;
    }

    mqttClient.connect();
    notifyListeners();
  }

  int? get loginId {
    int? uid = prefs.get(Constants.PREFS_LOGIN_ID) as int?;

    if (uid != null) {
      _loginId = uid;
      mqttClient.connect();

    }

    return uid;
  }
}
