import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:movie_gallery/mqtt/ChatPostMsg.dart';
import 'package:movie_gallery/mqtt/MyMqttClient.dart';
import 'package:movie_gallery/webrtc/SignalType.dart';

import '../mqtt/MsgType.dart';

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

  int _loginId;
  int _peerId;
  late RTCPeerConnection peerConnection;
  late RTCIceCandidate candidate;
  late MediaStream localStream;

  Future start() async {
    await candidate;
    _sendIceCandidate(candidate);
    await _sendOffer();
  }

  Future init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = localStream;

    peerConnection = await createPeerConnection({
      ..._iceServers,
      ...{'sdpSemantics': sdpSemantics}
    }, _config);
    for (var track in localStream.getTracks()) {
     await peerConnection.addTrack(track,localStream);
    }

    peerConnection.onTrack = (event) {
      if (event.track.kind == 'video') {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };
    peerConnection.onIceCandidate = (candidate) {
      this.candidate = candidate;
    };
  }

  void onSignalMessage(ChatPostMsg chatPostMsg) async {
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
      case SignalType.candidate:
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
    RTCSessionDescription localSessionDesc =
        await peerConnection.createAnswer();
    peerConnection.setLocalDescription(localSessionDesc);
    Map<String, dynamic> answerMap = {
      'type': SignalType.answer,
      'data': {'sdp': localSessionDesc.sdp, 'type': localSessionDesc.type},
    };
    ChatPostMsg chatPostMsg = ChatPostMsg(
        type: MsgType.SIGNAL,
        uid: _loginId,
        peerUid: _peerId,
        content: json.encode(answerMap));
    MyMqttClient.instance.publishMessage(chatPostMsg);
  }

  void _sendIceCandidate(RTCIceCandidate candidate) {
    Map<String, dynamic> iceMap = {
      'type': SignalType.candidate,
      'data': {
        'sdpMLineIndex': candidate.sdpMLineIndex,
        'sdpMid': candidate.sdpMid,
        'candidate': candidate.candidate,
      }
    };
    ChatPostMsg chatPostMsg = ChatPostMsg(
        type: MsgType.SIGNAL,
        uid: _loginId,
        peerUid: _peerId,
        content: json.encode(iceMap));
    MyMqttClient.instance.publishMessage(chatPostMsg);
  }

  Future<void> _sendOffer() async {
    RTCSessionDescription localSessionDesc = await peerConnection.createOffer();
    peerConnection.setLocalDescription(localSessionDesc);
    Map<String, dynamic> offerMap = {
      'type': SignalType.offer,
      'data': {'sdp': localSessionDesc.sdp, 'type': localSessionDesc.type},
    };
    ChatPostMsg chatPostMsg = ChatPostMsg(
        type: MsgType.SIGNAL,
        uid: _loginId,
        peerUid: _peerId,
        content: json.encode(offerMap));
    MyMqttClient.instance.publishMessage(chatPostMsg);
  }

  void dispose()async {
    for (var track in localStream.getTracks()) {
       await track.stop();
    }
    for (var track in _remoteRenderer.srcObject!.getTracks()) {
      await track.stop();
    }
    _remoteRenderer.dispose();
    _localRenderer.dispose();
    peerConnection.dispose();

  }

  RTCVideoRenderer get localRenderer => _localRenderer;

  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  WebRTCClient({
    required int loginId,
    required int peerId,
  })  : _loginId = loginId,
        _peerId = peerId;
}
