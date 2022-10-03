
import 'package:injectable/injectable.dart';

import '../mqtt/MyMqttClient.dart';
import 'RoomClient.dart';

@singleton
class RoomListener{
  MyMqttClient _mqttClient;
  RoomClient _roomClient;

  RoomListener(this._mqttClient, this._roomClient){
    _mqttClient.roomStreamController.stream.listen((event) {
      _roomClient.onMessage(event);
    });
  }
}
