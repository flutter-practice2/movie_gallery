import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:movie_gallery/AppErrorHandler.dart';
import 'package:movie_gallery/app_theme.dart';
import 'package:provider/provider.dart';

import 'AppEnvironment.dart';
import 'http/MyClient.dart';
import 'inject/injection.dart';
import 'login/LoginNotifier.dart';
import 'router.dart';
void main() async{
  await dotenv.load(fileName: AppEnvironment.envFile);

  _setupLogging();
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  AppErrorHandler(). registerErrorHandler();

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
      ],
      child: MaterialApp.router(
        theme: AppTheme.themeData(),
        routerConfig: router,
        debugShowCheckedModeBanner:false,

      ),
    );
  }


}
