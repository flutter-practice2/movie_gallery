import 'package:json_annotation/json_annotation.dart';

part 'User.g.dart';

@JsonSerializable()
class User {

	factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
	Map<String, dynamic> toJson( ) => _$UserToJson(this);

  int? uid;

  String? nickname;

  String? avatar;

  String? phone_number;

  User({
    this.uid,
    this.nickname,
    this.avatar,
    this.phone_number,
  });



}
