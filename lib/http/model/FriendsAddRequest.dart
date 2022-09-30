import 'package:json_annotation/json_annotation.dart';


part 'FriendsAddRequest.g.dart';

@JsonSerializable(explicitToJson: true)
class FriendsAddRequest {

	factory FriendsAddRequest.fromJson(Map<String, dynamic> json) => _$FriendsAddRequestFromJson(json);
	Map<String, dynamic> toJson( ) => _$FriendsAddRequestToJson(this);

  int uid;
  int friend_uid;

  FriendsAddRequest({
    required this.uid,
    required this.friend_uid,
  });


}
