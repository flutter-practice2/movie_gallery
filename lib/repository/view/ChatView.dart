import 'package:floor/floor.dart';

@DatabaseView(
    'select c.id,c.unread,u.nickname,u.avatar  from chat c inner join user u on c.id=u.uid',
    viewName: 'chat_view')
class ChatView {
  int id; //uid
  int? unread;
  String? nickname;
  String? avatar;

  ChatView({
    required this.id,
    this.unread,
    this.nickname,
    this.avatar,
  });

  @override
  String toString() {
    return '{id: $id, unread: $unread, nickname: $nickname, avatar: $avatar}';
  }
}
