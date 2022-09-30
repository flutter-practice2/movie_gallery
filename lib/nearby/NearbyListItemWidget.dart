
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../http/model/UserGeoLocationSearchNearbyResponse.dart';

class NearbyListItem extends StatelessWidget{

  UserLocationProjection item;


  NearbyListItem(this.item);

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        //avatar
        item.avatar != null && item.avatar!.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: item.avatar ?? '',
          width: 100,
          height: 100,
        )
            : Container(
          width: 100,
          height: 100,
          child: Icon(Icons.person),
        ),
        Text(item.nickname ?? '',style: Theme.of(context).textTheme.bodyText1,),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(item.distance != null
                  ? (item.distance! / 1000).toStringAsFixed(1) +
                  ' km'
                  : '',style: Theme.of(context).textTheme.bodyText1,),
              SizedBox(
                width: 8,
              )
            ],
          ),
        )
      ],
    );
  }
}
