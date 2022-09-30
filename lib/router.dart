import 'package:go_router/go_router.dart';
import 'package:movie_gallery/Constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';
import 'inject/injection.dart';
import 'login/LoginNotifier.dart';
import 'login/LoginWidget.dart';
import 'myself/DisplayPictureScreen.dart';
import 'myself/MyselfWidget.dart';
import 'myself/TakePictureScreen.dart';

final GoRouter router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) {
      int currentIndex= int.parse(state.queryParams['currentIndex']??'0');

      return Consumer<LoginNotifier>(
        builder: (context, notifier, child) {
          int? uid = Provider.of<LoginNotifier>(context).loginId;
          return uid != null ? HomePage(currentIndex:currentIndex) : LoginWidget();
          // return HomePage();
        },
      );
    },
  ),
  GoRoute(
    path: '/MyselfWidget',
    builder: (context, state) {
      return MyselfWidget();
    },
  ),
  GoRoute(
    path: '/TakePictureScreen',
    builder: (context, state) {
      return TakePictureScreen();
    },
  ),
  GoRoute(
    path: '/DisplayPictureScreen',
    builder: (context, state) {
      String imagePath = state.queryParams['imagePath']!;
      print('receive_imagePath:$imagePath');
      return DisplayPictureScreen(imagePath);
    },
  )
]);
