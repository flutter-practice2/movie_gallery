/// nickname : "test_18780a2b64df"
/// avatar : "test_6860cbeb5e87"
/// phone_number : "test_54b0b76f19a0"

class UserRegisterRequest {
  String? _nickname;
  String? _avatar;
  String? _phoneNumber;


  UserRegisterRequest({
    String? nickname,
    String? avatar,
    String? phoneNumber,
  }) {
    _nickname = nickname;
    _avatar = avatar;
    _phoneNumber = phoneNumber;
  }

  UserRegisterRequest.fromJson(dynamic json) {
    _nickname = json['nickname'];
    _avatar = json['avatar'];
    _phoneNumber = json['phone_number'];
  }



  UserRegisterRequest copyWith({
    String? nickname,
    String? avatar,
    String? phoneNumber,
  }) =>
      UserRegisterRequest(
        nickname: nickname ?? _nickname,
        avatar: avatar ?? _avatar,
        phoneNumber: phoneNumber ?? _phoneNumber,
      );

  String? get nickname => _nickname;

  String? get avatar => _avatar;

  String? get phoneNumber => _phoneNumber;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['nickname'] = _nickname;
    map['avatar'] = _avatar;
    map['phone_number'] = _phoneNumber;
    return map;
  }
}
