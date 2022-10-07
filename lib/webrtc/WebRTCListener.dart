import 'package:injectable/injectable.dart';

import '../mqtt/ChatPostMsg.dart';
import '../mqtt/MyMqttClient.dart';

@singleton
class WebRTCListener {
  MyMqttClient _mqttClient;
  static Function(ChatPostMsg)? onSignalMessage;

  WebRTCListener(this._mqttClient) {
    _mqttClient.signalStreamController.stream.listen((ChatPostMsg event) {
      print('webrtc_signalStream:$event');

      if(onSignalMessage!=null) {
        onSignalMessage!.call(event);
      }
    });
  }

}
