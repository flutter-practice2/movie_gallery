

import 'package:flutter/material.dart';
import 'package:movie_gallery/inject/injection.dart';
import 'package:movie_gallery/repository/entity/ChatMessageEntity.dart';
import '../repository/ChatMessageRepository.dart';

class ImeWidget extends StatefulWidget {
  final int loginId;
  final int peerId;

  ImeWidget(this.loginId,this.peerId);

  @override
  State<ImeWidget> createState() => _ImeWidgetState();
}

class _ImeWidgetState extends State<ImeWidget> {
  ChatMessageRepository chatMessageRepository = getIt<ChatMessageRepository>();
  TextEditingController textEditingController=TextEditingController();
  String? text;
  @override
  void initState() {
    super.initState();

    textEditingController.addListener(() {
     print('ime_text:$text,${text?.length??'null'}');
     setState(() {
       text= textEditingController.text;
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
              margin: EdgeInsets.only(
                left:8
              ),
              height: 35,
              decoration: BoxDecoration(
                border: Border.all(style: BorderStyle.none),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white
              ),
              child: TextField(controller: textEditingController,
              decoration:  InputDecoration(
                border: InputBorder.none
              ),
              ),
            ),
          ),
         this.text!=null&&this.text!.isNotEmpty ?
         TextButton(onPressed: () {
           if(this.text!=null&&this.text!.isNotEmpty ) {
             ChatMessageEntity entity=ChatMessageEntity( chatId: widget.peerId, uid: widget.loginId, message: this.text!);
             this.chatMessageRepository.insert(entity);
           }

           this.textEditingController.clear();
           setState(() {
             this.text=null;
           });


         }, child: Text('Send'),
         ):
         IconButton(onPressed: () {
          //todo
          }, icon: Icon(Icons.add)
          )

        ],
      ),
    );
  }
}
