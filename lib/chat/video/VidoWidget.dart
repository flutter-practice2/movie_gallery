import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/webrtc/RoomType.dart';
import 'package:movie_gallery/webrtc/WebRTCListener.dart';

import '../../webrtc/RoomClient.dart';
import '../../webrtc/WebRTCClient.dart';

class VideoWidget extends StatefulWidget {
  int _loginId;
  int _peerId;

  VideoWidget({
    required int loginId,
    required int peerId,
  })  : _loginId = loginId,
        _peerId = peerId;

  @override
  State<VideoWidget> createState() => _VideoWidgetState(
        loginId: _loginId,
        peerId: _peerId,
      );
}

class _VideoWidgetState extends State<VideoWidget> {
  int _loginId;
  int _peerId;
  late WebRTCClient webRTCClient;
  bool isConnected = false;

  RoomClient roomClient = getIt<RoomClient>();

  _VideoWidgetState({
    required int loginId,
    required int peerId,
  })  : _loginId = loginId,
        _peerId = peerId {
    webRTCClient = WebRTCClient(loginId: _loginId, peerId: _peerId);
  }

  @override
  void initState() {
    super.initState();
    RoomClient.roomUiCallback = onRoomMessage;

    webRTCClient.init().then((value) {
      WebRTCListener.signalOnMessage = webRTCClient.onMessage;
      roomClient.sendInvite(_loginId, _peerId);
    });

  }

  void onRoomMessage(String type) {
    switch(type){
      case RoomType.AGREE:
        setState(() {
          isConnected=true;
        });
        break;
      case RoomType.REJECT:
        //todo  response to reject
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: RTCVideoView(webRTCClient.remoteRenderer),
            )),
        Positioned(
            left: 20,
            top: 20,
            child: Container(
              width: 90,
              height: 120,
              child: RTCVideoView(
                webRTCClient.localRenderer,
                mirror: true,
              ),
            ))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    WebRTCListener.signalOnMessage = null;
    webRTCClient.dispose();
  }
}
