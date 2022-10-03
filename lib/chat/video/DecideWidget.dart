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
    return Center(
      child: Row(
        children: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('agree')),
          SizedBox(
            width: 10,
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);

              },
              child: Text('reject'))
        ],
      ),
    );
  }
}
