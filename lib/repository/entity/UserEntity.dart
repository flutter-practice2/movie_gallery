import 'package:json_annotation/json_annotation.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'user')
class UserEntity{
  @PrimaryKey()
  int uid;

  String? nickname;

  String? avatar;


  UserEntity({
    required this.uid,
    this.nickname,
    this.avatar,
  });


}
