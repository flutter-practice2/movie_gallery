
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_gallery/widget/Avatar.dart';

import '../http/model/UserGeoLocationSearchNearbyResponse.dart';

class NearbyListItemWidget extends StatelessWidget {
  UserLocationProjection item;

  NearbyListItemWidget(this.item);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Avatar(item.avatar, 100, 100),
        Text(
          item.nickname ?? '',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildDistanceText(context),
              SizedBox(
                width: 8,
              )
            ],
          ),
        )
      ],
    );
  }

  Text buildDistanceText(BuildContext context) {
    return Text(
      item.distance != null
          ? (item.distance! / 1000).toStringAsFixed(1) + ' km'
          : '',
      style: Theme.of(context).textTheme.bodyText1,
    );
  }
}
