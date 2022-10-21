import 'package:flutter/material.dart';
import 'package:movie_gallery/chat/video/VidoWidget.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/repository/entity/ChatMessageEntity.dart';

import './ChatDetailWidget6.dart';
import '../mqtt/ChatPostMsg.dart';
import '../mqtt/MsgType.dart';
import '../mqtt/MyMqttClient.dart';
import '../repository/ChatMessageRepository.dart';

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
  bool showPallet = false;

  _ImeWidgetState(this.state);

  @override
  void initState() {
    super.initState();

    textEditingController.addListener(() {
      print('ime_text:$text,${text?.length ?? 'null'}');
      setState(() {
        text = textEditingController.text;
        showPallet=false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            color: Color.fromRGBO(245, 245, 245, 1),
            height: 45,
            child: Row(
              children: [buildTextInput(), buildRightButton()],
            )),
        showPallet ? buildPallet() : SizedBox.shrink()
      ],
    );
  }

  Widget buildPallet() {
    return Container(
        height: 70,
        width: double.infinity,
        alignment: Alignment.center,
        child: IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoWidget(loginId: state.loginId, peerId: state.peerId
              ,isCaller: true,),));
              setState(() {
                this.showPallet = false;
              });
            },
            icon: Icon(Icons.video_call,size: 40,))
    );
  }

  Widget buildRightButton() {
    return this.text != null && this.text!.isNotEmpty
        ? TextButton(
            onPressed: () {
              String? content = this.text;
              if (content != null && content.isNotEmpty) {
                ChatMessageEntity entity = ChatMessageEntity(
                    chatId: state.peerId, uid: state.loginId, message: content);
                this.chatMessageRepository.insert(entity).then((value) {
                  // state.prepend([entity]);
                  state.incrDbPagingOffset();
                  state.prependFromDb();

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
              setState(() {
                showPallet = !showPallet;
              });
            },
            icon: Icon(Icons.add));
  }

  Expanded buildTextInput() {
    return Expanded(
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
    );
  }

  void sendMessageToPeer(String content) {
    ChatPostMsg chatPostMsg = ChatPostMsg(type: MsgType.CHAT,
        uid: state.loginId, peerUid: state.peerId, content: content);
    mqttClient.publishMessage(chatPostMsg);
  }
}
