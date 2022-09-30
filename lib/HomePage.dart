import 'package:flutter/material.dart';
import 'package:movie_gallery/chat/ChatListWidget.dart';
import 'package:movie_gallery/friends/FriendListWidget.dart';

import 'myself/MyselfWidget.dart';
import 'nearby/NearbyListWidget.dart';

class HomePage extends StatefulWidget {

  int currentIndex ;


  HomePage({this.currentIndex:0}){
    print('Home_construct,currentIndex:$currentIndex');

  }

  @override
  State<HomePage> createState() => _HomePageState();


}

class _HomePageState extends State<HomePage> {
  List<Widget> pages = [];
 late int currentIndex ;

  @override
  void initState() {
    currentIndex=widget.currentIndex;
    pages.add(new NearbyList());
    pages.add(new ChatListWidge());
    pages.add(new FriendListWidget());
    pages.add(new MyselfWidget());
    print('home_initState,currentIndex:$currentIndex');


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: new BottomNavigationBar(
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black45,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.near_me), label: 'near'),
          BottomNavigationBarItem(icon: Icon(Icons.chat),label: 'chat'),
          BottomNavigationBarItem(icon: Icon(Icons.people),label: 'friend'),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: 'me'),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: IndexedStack(
        children: pages,
        index: currentIndex,
      ),
    );
  }
}
