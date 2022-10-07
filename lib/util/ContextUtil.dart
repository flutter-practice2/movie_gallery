import 'package:flutter/material.dart';

class ContextUtil {
  static GlobalKey<NavigatorState> appKey = GlobalKey();
  static BuildContext get context => appKey.currentContext!;

}
