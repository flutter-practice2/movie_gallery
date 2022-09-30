// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FriendsAddRequest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendsAddRequest _$FriendsAddRequestFromJson(Map<String, dynamic> json) =>
    FriendsAddRequest(
      uid: json['uid'] as int,
      friend_uid: json['friend_uid'] as int,
    );

Map<String, dynamic> _$FriendsAddRequestToJson(FriendsAddRequest instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'friend_uid': instance.friend_uid,
    };
