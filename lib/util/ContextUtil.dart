import 'package:flutter/material.dart';

class ContextUtil {
  static GlobalKey appKey = GlobalKey();

 static BuildContext get context => appKey.currentContext!;
}
