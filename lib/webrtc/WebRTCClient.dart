import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:movie_gallery/mqtt/ChatPostMsg.dart';
import 'package:movie_gallery/mqtt/MyMqttClient.dart';
import 'package:movie_gallery/webrtc/SignalType.dart';
import 'package:movie_gallery/webrtc/UiEventType.dart';

import '../mqtt/MsgType.dart';
import 'WebRTCListener.dart';

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

  Map<String, dynamic> pcConfiguration = {
    'iceServers': [
      {'url': 'stun:socialme.hopto.org:3478'},
    ],
    // 'sdpSemantics': 'unified-plan'  //default
    'sdpSemantics': 'plan-b'
  };

  final Map<String, dynamic> pcConstraints = {
    'mandatory': {},
    'optional': [
    ]
  };

  int loginId;
  int peerId;
  late RTCPeerConnection peerConnection;
  late MediaStream localStream;
  Function(String) signalUiCallback;

  WebRTCClient({
    required this. loginId,
    required this. peerId,
    required this.signalUiCallback
  }) {
    WebRTCListener.onSignalMessage = this.onSignalMessage;

  }
  Future start() async {
    print('webrtc_start');
    await _sendOffer();

  }

  Future init() async {
    print('webrtc_init');
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = localStream;

    peerConnection = await createPeerConnection(pcConfiguration, pcConstraints);

    // await unifiedPlan();
    await planB();

    peerConnection.onIceCandidate = (candidate) {
      print('webrtc_onIceCandidate:$candidate');
      if(candidate.candidate!=null) {
        // this.candidate = candidate;
        peerConnection.addCandidate(candidate);
        // candidateCompleter.complete(true);
        _sendIceCandidate(candidate);
      }

    };

  }

  Future planB() async{
   await  peerConnection.addStream(localStream);
    peerConnection.onAddStream=(stream) {
      print('webrtc_onAddStream:$stream');
      _remoteRenderer.srcObject=stream;
      signalUiCallback.call(UiEventType.RTC_STARTED);
    };
  }

  Future<void> unifiedPlan() async {
     for (var track in localStream.getTracks()) {
      await peerConnection.addTrack(track, localStream);
    }
    peerConnection.onTrack = (event) {
      if (event.track.kind == 'video') {
        print('webrtc_onTrack:$event');
        _remoteRenderer.srcObject = event.streams[0];
        signalUiCallback.call(UiEventType.RTC_STARTED);
      }
    };
  }
  void onSignalMessage(ChatPostMsg chatPostMsg) async {
    print('webrtc_onSignalMessage:$chatPostMsg');
    Map<String, dynamic> map = json.decode(chatPostMsg.content);
    Map<String, dynamic> data = map['data'];
    switch (map['type']) {
      case SignalType.offer:
        peerConnection.setRemoteDescription(
            RTCSessionDescription(data['sdp'], data['type']));
        await _sendAnswer();

        break;
      case SignalType.answer:
        peerConnection.setRemoteDescription(
            RTCSessionDescription(data['sdp'], data['type']));

        break;
      case SignalType.ice_candidate:
        print('webrtc_receive_candidate');
        RTCIceCandidate candidate = RTCIceCandidate(
            data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
        peerConnection.addCandidate(candidate);

        break;
    }
  }

  void switchCamera() {
    Helper.switchCamera(localStream.getVideoTracks()[0]);
  }

  void alterMic() {
    localStream.getAudioTracks()[0].enabled =
        !localStream.getAudioTracks()[0].enabled;
  }

  Future<void> _sendAnswer() async {
    print('webrtc_sendAnswer');
    RTCSessionDescription localSessionDesc =
        await peerConnection.createAnswer();
    peerConnection.setLocalDescription(localSessionDesc);
    Map<String, dynamic> answerMap = {
      'type': SignalType.answer,
      'data': {'sdp': localSessionDesc.sdp, 'type': localSessionDesc.type},
    };
    ChatPostMsg chatPostMsg = ChatPostMsg(
        type: MsgType.SIGNAL,
        uid: loginId,
        peerUid: peerId,
        content: json.encode(answerMap));
    MyMqttClient.instance.publishMessage(chatPostMsg);
  }

  Future _sendIceCandidate(RTCIceCandidate candidate) async {
    print('webrtc_sendIceCandidate_wait');
    // await candidateCompleter.future;
    Map<String, dynamic> iceMap = {
      'type': SignalType.ice_candidate,
      'data': {
        'sdpMLineIndex': candidate.sdpMLineIndex,
        'sdpMid': candidate.sdpMid,
        'candidate': candidate.candidate,
      }
    };
    ChatPostMsg chatPostMsg = ChatPostMsg(
        type: MsgType.SIGNAL,
        uid: loginId,
        peerUid: peerId,
        content: json.encode(iceMap));
    MyMqttClient.instance.publishMessage(chatPostMsg);
    print('webrtc_sendIceCandidate_done');
  }

  Future<void> _sendOffer() async {
    print('webrtc_sendOffer');
    RTCSessionDescription localSessionDesc = await peerConnection.createOffer();
    peerConnection.setLocalDescription(localSessionDesc);
    Map<String, dynamic> offerMap = {
      'type': SignalType.offer,
      'data': {'sdp': localSessionDesc.sdp, 'type': localSessionDesc.type},
    };
    ChatPostMsg chatPostMsg = ChatPostMsg(
        type: MsgType.SIGNAL,
        uid: loginId,
        peerUid: peerId,
        content: json.encode(offerMap));
    MyMqttClient.instance.publishMessage(chatPostMsg);
  }

  void dispose() async {
    for (var track in localStream.getTracks()) {
      await track.stop();
    }
    if (_remoteRenderer.srcObject != null) {
      for (var track in _remoteRenderer.srcObject!.getTracks()) {
        await track.stop();
      }
    }
    _remoteRenderer.dispose();
    _localRenderer.dispose();
    peerConnection.dispose();

    WebRTCListener.onSignalMessage =null;
  }

  RTCVideoRenderer get localRenderer => _localRenderer;

  RTCVideoRenderer get remoteRenderer => _remoteRenderer;


}
