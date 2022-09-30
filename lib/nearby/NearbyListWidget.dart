import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../http/MyClient.dart';
import '../http/model/export.dart';
import '../inject/injection.dart';
import 'NearbyDetailWidget.dart';
import 'NearbyListItemWidget.dart';

class NearbyList extends StatefulWidget {
  @override
  State createState() {
    return _NearbyListState();
  }
}

class _NearbyListState extends State<NearbyList> {
  double? latitude;
  double? longitude;
  bool locationRejected = false;
  bool locationDisabled = false;

  MyClient myClient = getIt<MyClient>();
  SharedPreferences prefs = getIt<SharedPreferences>();
  int? loginId;

  final PagingController<int, UserLocationProjection> pagingController =
      PagingController(firstPageKey: Constants.DEFAULT_PAGE);

  @override
  void initState() {
    super.initState();

    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    loginId = prefs.getInt(Constants.PREFS_LOGIN_ID);
  }

  int test_count = 0;

  @override
  Widget build(BuildContext context) {
    print('rebuild_test_trace ${test_count++}');
    return SafeArea(
      child: Container(
          child: Column(
        children: [
          Expanded(
            child: buildPageWidget(context),
          )
        ],
      )),
    );
  }

  Widget buildPageWidget(BuildContext context) {
    if (longitude == null) {
      getLocation();
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (locationRejected) {
      print('locationRejected');
      return Center(
        child: TextButton(
            onPressed: () async {
              await getLocation();
            },
            child: Text('permit location')),
      );
    } else if (locationDisabled) {
      print('locationDisabled');
      return Center(
        child: TextButton(
          child: Text('enable location'),
          onPressed: () async {
            await getLocation();
          },
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: () async {
          pagingController.refresh();
        },
        child: PagedListView<int, UserLocationProjection>(
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4.0,
                    top: 4,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return NearbyDetailWidget(item);
                        },
                      ));
                    },
                    child: NearbyListItem(item),
                  ),
                );
              },
            )),
      );
    }
  }

  Future _fetchPage(pageKey) async {
    print('_fetchPage,pageNumber:$pageKey');
    try {
      Response<UserGeoLocationSearchNearbyResponse> response = await myClient
          .searchNearby(latitude!, longitude!, pageKey, Constants.PAGE_SIZE);
      if (response.isSuccessful) {
        List<UserLocationProjection>? list = response.body?.list;
        if (list != null) {
          if (list.length < Constants.PAGE_SIZE) {
            pagingController.appendLastPage(list);
          } else {
            pagingController.appendPage(list, pageKey + 1);
          }
        }
      } else {
        print(response);
        pagingController.error(response);
      }
    } catch (e) {
      print(e);
      pagingController.error(e);
    }
  }

  Future getLocation() async {
    try {
      Position? position = await _determinePosition();
      print('got_location:$position');

      if (position != null) {
        setState(() {
          setPosition(position);
        });
      }
    } on LocationDisabledException catch (e, s) {
      setState(() {
        locationDisabled = true;
      });
      print('$e, $s');
    } on LocationRejectedException catch (e, s) {
      setState(() {
        locationRejected = true;
      });
      print('$e, $s');
    } catch (e, s) {
      print('$e, $s');
    }
  }

  Future<Position?> _determinePosition() async {
    bool locationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!locationServiceEnabled) {
      return Future.error(
          LocationDisabledException('Location services are disabled.'));
    }
    var locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        return Future.error(
            LocationRejectedException('Location permissions are denied'));
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      return Future.error(LocationRejectedException(
          'Location permissions are permanently denied, we cannot request permissions.'));
    }

    Geolocator.getPositionStream(
            locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high, distanceFilter: 100))
        .listen((Position? position) {
      if (position != null) {
        print('position_event');
        setPosition(position);
      }
    });

    print('get_location');
    return Geolocator.getLastKnownPosition(forceAndroidLocationManager: true);
  }

  void setPosition(Position position) {
    latitude = position.latitude;
    longitude = position.longitude;
    locationRejected = false;
    locationDisabled = false;

    if (loginId != null) {
      UserGeoLocationAddLocationRequest request =
          UserGeoLocationAddLocationRequest(
              latitude: latitude, longitude: longitude, uid: loginId);
      myClient
          .addLocation(request)
          .then((response) => print('report_location: $response'));
    }
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }
}

class LocationRejectedException implements Exception {
  final String message;

  LocationRejectedException(this.message);
}

class LocationDisabledException implements Exception {
  final String message;

  LocationDisabledException(this.message);
}
