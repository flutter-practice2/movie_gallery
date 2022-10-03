import 'package:injectable/injectable.dart';

import '../mqtt/ChatPostMsg.dart';
import '../mqtt/MyMqttClient.dart';

@singleton
class WebRTCListener {
  MyMqttClient _mqttClient;
  static Function(ChatPostMsg)? signalOnMessage;

  WebRTCListener(this._mqttClient) {
    _mqttClient.signalStreamController.stream.listen((ChatPostMsg event) {
      print('message_in:$event');

      if(signalOnMessage!=null) {
        signalOnMessage ?? (event);
      }
    });
  }

}
