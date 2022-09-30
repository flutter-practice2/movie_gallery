class UserGetDetailResponse {
  UserGetDetailResponse({
    this.uid,
    this.nickname,
    this.avatar,
    this.phoneNumber,
  });

  UserGetDetailResponse.fromJson(dynamic json) {
    uid = json['uid'];
    nickname = json['nickname'];
    avatar = json['avatar'];
    phoneNumber = json['phone_number'];
  }

  int? uid;
  String? nickname;
  String? avatar;
  String? phoneNumber;

  UserGetDetailResponse copyWith({
    int? uid,
    String? nickname,
    String? avatar,
    String? phoneNumber,
  }) =>
      UserGetDetailResponse(
        uid: uid ?? this.uid,
        nickname: nickname ?? this.nickname,
        avatar: avatar ?? this.avatar,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uid'] = uid;
    map['nickname'] = nickname;
    map['avatar'] = avatar;
    map['phone_number'] = phoneNumber;
    return map;
  }
}
