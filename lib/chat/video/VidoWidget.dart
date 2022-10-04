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
  RoomClient roomClient = getIt<RoomClient>();

  bool eglRenderInitialized=false;
  bool isConnected = false;
  bool micEnabled = true;

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
      WebRTCListener.signalOnMessage = webRTCClient.onSignalMessage;
      roomClient.sendInvite(_loginId, _peerId);
      setState(() {
        eglRenderInitialized=true;
      });
    });
  }

  void onRoomMessage(String type) {
    switch (type) {
      case RoomType.AGREE:
        webRTCClient.start();
        setState(() {
          isConnected = true;
        });
        break;
      case RoomType.REJECT:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('rejected')));
        hangUp();
        break;
      case RoomType.BYE:
        hangUp();
        break;
    }
  }

  void switchCamera() {
    webRTCClient.switchCamera();
  }

  void alterMic() {
    webRTCClient.alterMic();
    setState(() {
      micEnabled = !micEnabled;
    });
  }

  void hangUp() {
    Navigator.pop(context);
    close();
  }

  void close(){
    WebRTCListener.signalOnMessage = null;
    webRTCClient.dispose();
    RoomClient.roomUiCallback = null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !eglRenderInitialized?SizedBox.shrink(): Stack(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: 'alterMic',
              onPressed: () {
                alterMic();
              },
              child: micEnabled ? Icon(Icons.mic) : Icon(Icons.mic_off),
            ),
            FloatingActionButton(
              heroTag: 'hangUp',
              onPressed: () {
                hangUp();
              },
              backgroundColor: Colors.pink,
              child: Icon(Icons.call_end),
            ),
            FloatingActionButton(
              heroTag: 'switchCamera',
              onPressed: () {
                switchCamera();
              },
              child: Icon(Icons.switch_camera),
            ),
          ],
        ),
      ),
    );
  }


}
