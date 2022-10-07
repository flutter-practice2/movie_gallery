import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/webrtc/RoomType.dart';
import 'package:movie_gallery/webrtc/UiEventType.dart';

import '../../mqtt/ChatPostMsg.dart';
import '../../webrtc/RoomClient.dart';
import '../../webrtc/WebRTCClient.dart';

class VideoWidget extends StatefulWidget {
  int loginId;
  int peerId;
  bool isCaller;

  VideoWidget(
      {required this. loginId, required this. peerId, required this. isCaller})
      ;

  @override
  State<VideoWidget> createState() => _VideoWidgetState(
        loginId: loginId,
        peerId: peerId,
      );
}

class _VideoWidgetState extends State<VideoWidget> {
  int loginId;
  int peerId;
  late WebRTCClient webRTCClient;
  RoomClient roomClient = getIt<RoomClient>();

  bool eglRenderInitialized = false;
  bool connected = false;
  bool micEnabled = true;

  _VideoWidgetState({
    required this. loginId,
    required this.  peerId,
  })   {
    webRTCClient = WebRTCClient(
        loginId: loginId,
        peerId: peerId,
        signalUiCallback: this.signalUiCallback);
    RoomClient.roomUiCallback = roomUiCallback;
  }

  @override
  void initState() {
    super.initState();

    webRTCClient.init().then((value) {
      if (widget.isCaller) {
        roomClient.sendInvite(loginId, peerId);
      } else {
        roomClient.sendAgree(loginId, peerId);
      }
      setState(() {
        eglRenderInitialized = true;
      });
      print('webrtc_inited');
    });
  }

  void roomUiCallback(String type) {
    print('webrtc_roomUiCallback:$type');
    switch (type) {
      case RoomType.AGREE:
        webRTCClient.start();

        break;
      case RoomType.REJECT:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('rejected')));
        hangUp(false);
        break;
      case RoomType.BYE:
        hangUp(false);
        break;
    }
  }

  void signalUiCallback(String event) {
    switch(event){
      case UiEventType.RTC_STARTED:
        setState(() {
          print('webrtc_isConnected');
          this.connected=true;
        });
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

  void hangUp(bool isFromSelf) {
    if (isFromSelf) {
      roomClient.sendBye(loginId, peerId);
    }
    Navigator.pop(context);
    close();
  }

  void close() {
    webRTCClient.dispose();
    RoomClient.roomUiCallback = null;
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                !connected
                    ? SizedBox.shrink()
                    : Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: RTCVideoView(webRTCClient.remoteRenderer),
                        )),
                !eglRenderInitialized
                    ? SizedBox.shrink()
                    : Align(
                        alignment: Alignment.topRight,
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
          ),
          Container(
            alignment: Alignment.center,
            height: 100,
            padding: EdgeInsets.symmetric(horizontal: 8),
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
                    hangUp(true);
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
        ],
      ),
    );
  }
}
