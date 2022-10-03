import 'package:json_annotation/json_annotation.dart';

part 'ChatPostMsg.g.dart';

class MsgType {
  static const String TYPE_CHAT = 'chat';
  static const String TYPE_SIGNAL = 'signal';
}

@JsonSerializable()
class ChatPostMsg {
  factory ChatPostMsg.fromJson(Map<String, dynamic> json) =>
      _$ChatPostMsgFromJson(json);

  Map<String, dynamic> toJson() => _$ChatPostMsgToJson(this);
  String type; //see MsgType
  int uid;
  int peerUid;
  String content;


  @override
  String toString() {
    return '{type: $type, uid: $uid, peerUid: $peerUid, content: $content}';
  }

  ChatPostMsg({
    this.type: MsgType.TYPE_CHAT,
    required this.uid,
    required this.peerUid,
    required this.content,
  });
}
