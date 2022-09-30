import 'package:floor/floor.dart';

@Entity(tableName: 'chat')
class ChatEntity{
  @PrimaryKey()
  int id;//uid
  int? unread;

  ChatEntity({
    required this.id,
     this.unread,
  });

  @override
  String toString() {
    return '{id: $id, unread: $unread}';
  }
}
