// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ChatPostMsg.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatPostMsg _$ChatPostMsgFromJson(Map<String, dynamic> json) => ChatPostMsg(
      uid: json['uid'] as int,
      peerUid: json['peerUid'] as int,
      content: json['content'] as String,
    );

Map<String, dynamic> _$ChatPostMsgToJson(ChatPostMsg instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'peerUid': instance.peerUid,
      'content': instance.content,
    };