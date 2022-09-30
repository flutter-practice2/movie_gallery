import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Container(

        child: Platform.isIOS ?
        CupertinoActivityIndicator()
            : CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme
                .of(context)
                .colorScheme
                .primary,
          ),

        )
    );
  }
}
