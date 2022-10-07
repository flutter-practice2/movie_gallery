import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../util/ContextUtil.dart';

class DecideWidget extends StatelessWidget {
  int loginId;
  int peerId;

  DecideWidget(this.loginId, this.peerId);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('agree')),
          SizedBox(
            width: 10,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);

              },
              child: Text('reject'))
        ],
      ),
    );
  }
}
