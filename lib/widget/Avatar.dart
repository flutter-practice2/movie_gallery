import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  String? avatar;
  final double width;
  final double height;

  Avatar(
    this.avatar,
    this.width,
    this.height,
  );

  @override
  Widget build(BuildContext context) {
    return avatar == null
        ? Container(
            height: height,
            width: width,
            child: Icon(Icons.person),
          )
        : CachedNetworkImage(
            imageUrl: avatar!,
      height: height,
      width: width,
          );
  }
}
