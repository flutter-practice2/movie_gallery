import 'package:flutter/material.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/repository/entity/ChatMessageEntity.dart';
import '../../mqtt/ChatPostMsg.dart';
import '../../mqtt/MsgType.dart';
import '../../mqtt/MyMqttClient.dart';
import '../../repository/ChatMessageRepository.dart';
import 'ChatDetailWidget3.dart';

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
                        bool atBottom = state.isAtBottom();
                        print('current_is_at_bottom:$atBottom');

                        // send message to peer
                        // sendMessageToPeer();
                        ChatPostMsg chatPostMsg = ChatPostMsg(
                            type: MsgType.CHAT,
                            uid: state.loginId,
                            peerUid: state.peerId,
                            content: content);
                        mqttClient.publishMessage(chatPostMsg);

                        if (atBottom) {
                          state.refresh();
                        }else{
                          state.incrOffset();
                        }
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

  void sendMessageToPeer() {
    ChatPostMsg chatPostMsg = ChatPostMsg(
        type: MsgType.CHAT,
        uid: state.loginId,
        peerUid: state.peerId,
        content: this.text!);
    mqttClient.publishMessage(chatPostMsg);
  }
}
