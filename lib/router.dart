import 'package:go_router/go_router.dart';
import 'package:movie_gallery/util/ContextUtil.dart';
import 'package:provider/provider.dart';

import 'HomePage.dart';
import 'chat/video/VidoWidget.dart';
import 'login/LoginNotifier.dart';
import 'login/LoginWidget.dart';
import 'myself/DisplayPictureScreen.dart';
import 'myself/MyselfWidget.dart';
import 'myself/TakePictureScreen.dart';

final GoRouter router = GoRouter(
    navigatorKey:ContextUtil.appKey,
    routes: [
  GoRoute(
    path: '/',
    builder: (context, state) {
      int currentIndex = int.parse(state.queryParams['currentIndex'] ?? '0');
      return Consumer<LoginNotifier>(
        builder: (context, notifier, child) {
          int? uid = Provider.of<LoginNotifier>(context).loginId;
          return uid != null
              ? HomePage(currentIndex: currentIndex)
              : LoginWidget();
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
  ),
  GoRoute(
    path: '/VideoWidget',
    builder: (context, state) {
      int loginId = int.parse(state.queryParams['loginId']!);
      int peerId = int.parse(state.queryParams['peerId']!);
      bool isCaller = 'true'==(state.queryParams['isCaller']!)?true:false;
      return VideoWidget(
        loginId: loginId,
        peerId: peerId,
        isCaller: isCaller,
      );
    },
  ),

]);
