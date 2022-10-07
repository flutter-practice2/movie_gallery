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
  bool isCaller;

  VideoWidget(
      {required int loginId, required int peerId, required bool isCaller})
      : _loginId = loginId,
        _peerId = peerId,
        this.isCaller = isCaller;

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

  bool eglRenderInitialized = false;
  bool isConnected = false;
  bool micEnabled = true;

  _VideoWidgetState({
    required int loginId,
    required int peerId,
  })  : _loginId = loginId,
        _peerId = peerId {
    webRTCClient = WebRTCClient(loginId: _loginId, peerId: _peerId);
    RoomClient.roomUiCallback = roomUiCallback;
    WebRTCListener.onSignalMessage = webRTCClient.onSignalMessage;
  }

  @override
  void initState() {
    super.initState();

    webRTCClient.init().then((value) {
      if (widget.isCaller) {
        roomClient.sendInvite(_loginId, _peerId);
      } else {
        setState(() {
          print('webrtc_isConnected');
          isConnected = true;
        });
        roomClient.sendAgree(_loginId, _peerId);
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
        webRTCClient.start().then((value) {
          setState(() {
            print('webrtc_isConnected');
            isConnected = true;
          });
        })
        ;

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
      roomClient.sendBye(_loginId, _peerId);
    }
    Navigator.pop(context);
    close();
  }

  void close() {
    WebRTCListener.onSignalMessage = null;
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
                !isConnected
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
