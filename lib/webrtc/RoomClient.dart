import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:movie_gallery/chat/video/DecideWidget.dart';
import 'package:movie_gallery/mqtt/ChatPostMsg.dart';
import 'package:movie_gallery/mqtt/MsgType.dart';
import 'package:movie_gallery/mqtt/MyMqttClient.dart';
import 'package:movie_gallery/webrtc/RoomType.dart';

import '../util/ContextUtil.dart';

@singleton
class RoomClient {
  MyMqttClient _mqttClient;
  static Function(String)? roomUiCallback;

  RoomClient(this._mqttClient);

  void onRoomMessage(ChatPostMsg event) async {
    print('webrtc_onRoomMessage:$event');
    Map<String, dynamic> map = json.decode(event.content);
    Map<String, dynamic> data = map['data'];
    String type = map['type'];
    switch (type) {
      case RoomType.INVITE:
        int loginId = data['peerId'];
        int peerId = data['loginId'];
        bool accept = (await Navigator.of(ContextUtil.context)
            .push<bool>(MaterialPageRoute<bool>(
          builder: (context) {
            return DecideWidget(loginId, peerId);
          },
        )))!;
        if (accept) {
          GoRouter.of(ContextUtil.context)
              .go('/VideoWidget?loginId=$loginId&peerId=$peerId&isCaller=false');
        } else {
          sendReject(loginId, peerId);
        }
        break;

      case RoomType.AGREE:
      case RoomType.REJECT:

        break;
    }
    if (roomUiCallback != null) {
      roomUiCallback!.call(type);
    }else{
      print('roomUiCallback is null');
    }

  }

  void sendReject(int loginId, int peerId) {
    String roomType = RoomType.REJECT;
    _sendRoomMessage(roomType, loginId, peerId);
  }

  void sendAgree(int loginId, int peerId) {
    String roomType = RoomType.AGREE;
    _sendRoomMessage(roomType, loginId, peerId);
  }
  void sendBye(int loginId, int peerId) {
    String roomType = RoomType.BYE;
    _sendRoomMessage(roomType, loginId, peerId);
  }

  void sendInvite(int loginId, int peerId) {
    String roomType = RoomType.INVITE;
    _sendRoomMessage(roomType, loginId, peerId);
  }

  void _sendRoomMessage(String roomType, int loginId, int peerId) {
    Map<String, dynamic> map = {
      'type': roomType,
      'data': {'loginId': loginId, 'peerId': peerId}
    };
    String content = json.encode(map);
    ChatPostMsg chatPostMsg = ChatPostMsg(
        type: MsgType.ROOM, uid: loginId, peerUid: peerId, content: content);
    _mqttClient.publishMessage(chatPostMsg);
  }
}
