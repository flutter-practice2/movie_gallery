import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCClient {
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final Map<String, dynamic> mediaConstraints = {
    'audio': true,
    'video': {
      'mandatory': {
        'minWidth': '640', // Provide your own width, height and frame rate here
        'minHeight': '480',
        'minFrameRate': '30',
      },
      'facingMode': 'user',
      'optional': [],
    }
  };
  Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:socialme.hopto.org:3478'},
    ]
  };

  String get sdpSemantics => 'unified-plan';

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ]
  };

  void init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    MediaStream localStream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = localStream;

    RTCPeerConnection pc = await createPeerConnection({
      ..._iceServers,
      ...{'sdpSemantics': sdpSemantics}
    }, _config);

    pc.onTrack = (event) {
      if (event.track.kind == 'video') {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    for (var track in localStream.getTracks()) {
      pc.addTrack(track);
    }


  }

  void dispose() {
    _remoteRenderer.dispose();
    _localRenderer.dispose();
  }

  RTCVideoRenderer get localRenderer => _localRenderer;

  RTCVideoRenderer get remoteRenderer => _remoteRenderer;
}
