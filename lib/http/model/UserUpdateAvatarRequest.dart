

class UserUpdateAvatarRequest{
  int? uid;
  String? avatar;

  UserUpdateAvatarRequest({
    this.uid,
    this.avatar,
  });

  factory UserUpdateAvatarRequest.fromJson(Map<String, dynamic> json) {
    return UserUpdateAvatarRequest(
      uid: int.parse(json["uid"]),
      avatar: json["avatar"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": this.uid,
      "avatar": this.avatar,
    };
  }

//

}
