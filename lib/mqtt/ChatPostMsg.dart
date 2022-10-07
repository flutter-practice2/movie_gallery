import 'package:json_annotation/json_annotation.dart';
import 'MsgType.dart';
part 'ChatPostMsg.g.dart';


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
    required this.type,
    required this.uid,
    required this.peerUid,
    required this.content,
  });
}
