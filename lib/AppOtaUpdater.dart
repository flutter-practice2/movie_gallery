import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';

class AppOtaUpdater extends StatefulWidget {
  @override
  State<AppOtaUpdater> createState() => _AppOtaUpdaterState();
}

class _AppOtaUpdaterState extends State<AppOtaUpdater> {
  OtaEvent? currentEvent;
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    otaUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      color: Colors.white,
      child: currentEvent == null || currentEvent?.value == null
          ? Container()
          : this.isNumeric(currentEvent!.value!)
              ? LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                  value: double.parse(currentEvent!.value!) / 100,
                )
              : Text(currentEvent!.value!),
    );
  }


  void otaUpdate() async {
    String file;
    if (Platform.isAndroid) {
      file = 'https://socialme.hopto.org/static/ota_update/movie_gallery.apk';
    } else {
      //ios
      file = 'https://socialme.hopto.org/static/update/movie_gallery.ipa';
    }
    subscription = OtaUpdate().execute(file).listen((event) {
      setState(() {
        currentEvent = event;
      });
    });
  }

  @override
  void dispose() {
    subscription.cancel();

    super.dispose();
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}
