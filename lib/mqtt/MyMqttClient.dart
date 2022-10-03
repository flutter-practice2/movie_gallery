import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:movie_gallery/Constants.dart';
import 'package:movie_gallery/repository/ChatMessageRepository.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:retry/retry.dart';
import 'package:uuid/uuid.dart';
import '../repository/entity/ChatMessageEntity.dart';
import 'ChatPostMsg.dart';
import 'package:typed_data/typed_data.dart' as typed;

@singleton
class MyMqttClient {
  static late MyMqttClient _instance;
  SharedPreferences _prefs;
  ChatMessageRepository _chatMessageRepository;
  MqttClient? _client;
  final Lock _lock = Lock();
  final _uuid = Uuid();
  StreamController<ChatMessageEntity> streamController =
      StreamController.broadcast();

  StreamSubscription? messageSubscription;

  MyMqttClient(this._prefs, this._chatMessageRepository) {
    _instance = this;
  }

  static MyMqttClient get instance => _instance;

  Future<bool> connect() async {
    if (isConnected()) {
      print('mqtt_try_connect');
      return true;
    }
    return _lock.synchronized(() async {
      if (isConnected()) {
        return true;
      }
      var r = RetryOptions(
          delayFactor: Duration(milliseconds: 500),
          maxDelay: Duration(seconds: 30),
          maxAttempts: 4);

      try {
        return r.retry(() async {
          return await _doConnect();
        });
      } catch (e) {
        print(e);
        return false;
      }
    });
  }

  Future<bool> _doConnect() async {
    if (isConnected()) {
      return true;
    }
    int uid = _prefs.getInt(Constants.PREFS_LOGIN_ID)!;

    MqttClient mqttClient = MqttServerClient('socialme.hopto.org', _uuid.v4());
    // mqttClient.logging(on: true);
    mqttClient.onConnected = onConnected;
    mqttClient.onAutoReconnect = onAutoReconnect;
    mqttClient.onDisconnected = onDisconnected;
    mqttClient.onSubscribed = onSubscribed;
    mqttClient.onSubscribeFail = onSubscribeFail;
    mqttClient.onUnsubscribed = onUnsubscribed;
    mqttClient.pongCallback = pong;
    mqttClient.autoReconnect = true;
    mqttClient.resubscribeOnAutoReconnect = true;
    mqttClient.connectTimeoutPeriod = 3000;
    mqttClient.keepAlivePeriod = 30;

    mqttClient.connectionMessage = MqttConnectMessage();

    try {
      MqttClientConnectionStatus? connectionStatus = await mqttClient.connect();
      print('mqtt_connect_status: ${connectionStatus}');
      if (connectionStatus!.state != MqttConnectionState.connected) {
        throw Exception('mqtt_connect_state is not connected');
      }
    } catch (e, s) {
      print('mqtt_connect failure: $e,$s');
      throw e;
    }

    if (messageSubscription != null) {
      messageSubscription!.cancel();
    }
    if (this._client != null) {
      try {
        this._client!.disconnect();
      } catch (e) {
        print(e);
      }
    }

    mqttClient.subscribe("u/$uid", MqttQos.exactlyOnce);
    messageSubscription = mqttClient.updates!.listen(onMessage);

    this._client = mqttClient;
    print('mqtt_create_client');
    return true;
  }

  bool isConnected() {
    return _client != null &&
        _client!.connectionStatus!.state == MqttConnectionState.connected;
  }

  void publishMessage(ChatPostMsg chatPostMsg) async {
    bool connected = true;
    if (!isConnected()) {
      connected = await connect();
    }
    if (connected) {
      String topic = 'u/${chatPostMsg.peerUid}';
      String jsonStr = json.encode(chatPostMsg.toJson());
      print('mqtt_publishMessage:$jsonStr');
      var buffer = utf8StringToUinit8buffer(jsonStr);

      var payload = MqttClientPayloadBuilder()
          // .addUTF8String(jsonStr)
          .addBuffer(buffer)
          .payload!;
      _client!.publishMessage(topic, MqttQos.exactlyOnce, payload);
    } else {
      print('mqtt_publishing_message_is_dropped: $chatPostMsg');
    }
  }

  void onMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    MqttPublishMessage message = event[0].payload as MqttPublishMessage;
    // String payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
    String payload = uinit8bufferToUtf8String(message.payload.message);

    print('mqtt_onMessage:$payload');
    Map<String, dynamic> map = json.decode(payload);
    ChatPostMsg chatPostMsg = ChatPostMsg.fromJson(map);

    ChatMessageEntity entity = ChatMessageEntity(
        uid: chatPostMsg.uid,
        chatId: chatPostMsg.uid,
        message: chatPostMsg.content);
    _chatMessageRepository.insert(entity);

    streamController.add(entity);
  }

  static typed.Uint8Buffer utf8StringToUinit8buffer(String message) {
    var buffer = typed.Uint8Buffer();
    List<int> bytes = utf8.encode(message);
    buffer.addAll(Uint8List.fromList(bytes));
    return buffer;
  }

  static String uinit8bufferToUtf8String(typed.Uint8Buffer buffer) {
    List<int> codeUnits = buffer.toList();
    String str = utf8.decode(codeUnits);
    return str;
  }

// connection succeeded
  void onConnected() {
    print('mqtt_Connected');
  }

  void onAutoReconnect() {
    print('mqtt_AutoReconnect');
  }

  void onDisconnected() {
    print('mqtt_Disconnected');
  }

// subscribe to topic succeeded
  void onSubscribed(String topic) {
    print('mqtt_Subscribed topic: $topic');
  }

// subscribe to topic failed
  void onSubscribeFail(String topic) {
    print('mqtt_Failed to subscribe $topic');
  }

// unsubscribe succeeded
  void onUnsubscribed(String? topic) {
    print('mqtt_Unsubscribed topic: $topic');
  }

// PING response received
  void pong() {
    print('mqtt_Ping response client callback invoked');
  }
}
