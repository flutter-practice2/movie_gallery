import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../webrtc/MyWebRTCClient.dart';

class VideoWidget extends StatefulWidget {
  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {

  WebRTCClient webRTCClient=WebRTCClient();



  @override
  void initState() {
    super.initState();

    webRTCClient.init();

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
    webRTCClient.dispose();
  }
}
