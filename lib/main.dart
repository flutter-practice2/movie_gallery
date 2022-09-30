import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:movie_gallery/Constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';
import 'chat/MessageReceivedNotifier.dart';
import 'login/LoginNotifier.dart';
import 'login/LoginWidget.dart';
import 'http/MyClient.dart';
import 'inject/injection.dart';
import 'myself/MyselfWidget.dart';
import 'myself/TakePictureScreen.dart';
import 'nearby/NearbyDetailWidget.dart';
import 'router.dart';
void main() async{
  _setupLogging();
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  runApp(new MyApp());
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((event) {
    print('${event.level}: ${event.time}: ${event.message}');
  });
}

// only develop
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

class MyApp extends StatelessWidget {
  MyClient myClient=getIt<MyClient>();
  LoginNotifier loginNotifier=getIt<LoginNotifier>();
  MessageReceivedNotifier messageReceivedNotifier=getIt<MessageReceivedNotifier>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MyClient>(
          create: (context) => myClient,
          lazy: true,
        ),
        ChangeNotifierProvider(create: (context) => loginNotifier,),
        ChangeNotifierProvider(create: (context) => messageReceivedNotifier,)
      ],
      child: MaterialApp.router(
        routerConfig: router,
        
      ),
    );
  }


}
