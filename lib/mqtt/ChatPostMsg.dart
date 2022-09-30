import 'package:json_annotation/json_annotation.dart';
part 'ChatPostMsg.g.dart';


@JsonSerializable()
class ChatPostMsg {

	factory ChatPostMsg.fromJson(Map<String, dynamic> json) => _$ChatPostMsgFromJson(json);
	Map<String, dynamic> toJson( ) => _$ChatPostMsgToJson(this);
  int uid;
  int peerUid;
  String content;


  @override
  String toString() {
    return '{uid: $uid, peerUid: $peerUid, content: $content}';
  }

  ChatPostMsg({
    required this.uid,
    required this.peerUid,
    required this.content,
  });
}
