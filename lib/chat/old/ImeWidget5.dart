import 'package:flutter/material.dart';
import 'package:movie_gallery/chat/old/ChatDetailWidget5.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/mqtt/ChatPostMsg.dart';
import 'package:movie_gallery/mqtt/MsgType.dart';
import 'package:movie_gallery/mqtt/MyMqttClient.dart';
import 'package:movie_gallery/repository/ChatMessageRepository.dart';
import 'package:movie_gallery/repository/entity/ChatMessageEntity.dart';


class ImeWidget extends StatefulWidget {
  ChatDetailWidgetState state;

  ImeWidget(this.state);

  @override
  State<ImeWidget> createState() => _ImeWidgetState(state);
}

class _ImeWidgetState extends State<ImeWidget> {
  ChatMessageRepository chatMessageRepository = getIt<ChatMessageRepository>();
  MyMqttClient mqttClient = getIt<MyMqttClient>();
  TextEditingController textEditingController = TextEditingController();
  String? text;

  ChatDetailWidgetState state;

  _ImeWidgetState(this.state);

  @override
  void initState() {
    super.initState();

    textEditingController.addListener(() {
      print('ime_text:$text,${text?.length ?? 'null'}');
      setState(() {
        text = textEditingController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(245, 245, 245, 1),
      height: 45,
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 8),
              height: 35,
              decoration: BoxDecoration(
                  border: Border.all(style: BorderStyle.none),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white),
              child: TextField(
                controller: textEditingController,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
          this.text != null && this.text!.isNotEmpty
              ? TextButton(
                  onPressed: () {
                    String? content=this.text;
                    if (content != null && content.isNotEmpty) {
                      ChatMessageEntity entity = ChatMessageEntity(
                          chatId: state.peerId,
                          uid: state.loginId,
                          message: content);
                      this.chatMessageRepository.insert(entity).then((value) {
                        // state.prepend([entity]);
                        state.incrDbPagingOffset();
                        state.prependFromDb2();

                        // send message to peer
                        sendMessageToPeer(content);

                      });
                    }

                    this.textEditingController.clear();

                    setState(() {
                      this.text = null;
                    });
                  },
                  child: Text('Send'),
                )
              : IconButton(
                  onPressed: () {
                    //todo emerge panel
                  },
                  icon: Icon(Icons.add))
        ],
      ),
    );
  }

  void sendMessageToPeer(String content) {
     ChatPostMsg chatPostMsg = ChatPostMsg(
         type: MsgType.CHAT,
        uid: state.loginId,
        peerUid: state.peerId,
        content: content);
    mqttClient.publishMessage(chatPostMsg);
  }


}
