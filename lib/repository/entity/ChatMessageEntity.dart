import 'package:floor/floor.dart';

@Entity(tableName: 'chat_message')
class ChatMessageEntity{
  @PrimaryKey(autoGenerate: true)
  int? id;
  int chatId;// peer id of chat
  int uid;//who send the message
  String message;

  ChatMessageEntity({
     this.id,
    required this.chatId,
    required this.uid,
    required this.message,
  });

  @override
  String toString() {
    return '{id: $id, chatId: $chatId, uid: $uid, message: $message}';
  }
}
