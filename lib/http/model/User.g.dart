// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'User.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      uid: json['uid'] as int?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      phone_number: json['phone_number'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'uid': instance.uid,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
      'phone_number': instance.phone_number,
    };
