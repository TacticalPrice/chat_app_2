import 'package:chat_app_2/Authenticate/methods.dart';
import 'package:chat_app_2/screens/chatroom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../groupchats/group_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  Map<String,dynamic>? UserMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth  = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
   setStatus("Online");
  }

  void setStatus(String status) async{
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status" : status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      setStatus("Online");
    }else{
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1 ,String user2) {
    if(user1[0].toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]){
      return "$user1$user2";
    }else{
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    setState(() {
      isLoading = true;
    });

    await _firestore.collection('users').where("email", isEqualTo: _search.text).get().then((value) {
      setState(() {
        UserMap = value.docs[0].data();
        isLoading = false;
      });
      print(UserMap);
    });
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        actions: [
          IconButton(onPressed: () => logOut(context), icon: Icon(Icons.logout)),
        ],
      ),
      body: isLoading ? Center(
        child: Container(
          height: size.height / 20,
          width: size.width / 20,
          child: CircularProgressIndicator(),
        ),
      )
      : Column(
        children: [
          SizedBox(height: size.height / 20,),
          Container(
            height: size.height / 14,
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              height: size.height / 14,
              width: size.width / 1.15,
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: "Search",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
                )
              ),
            ),
          ),
          SizedBox(height: size.height / 50,),
          ElevatedButton(onPressed: onSearch, child: Text("Search")),
          SizedBox(height: size.height / 30),
          UserMap != null ? ListTile(
            onTap: () {
              String roomId = chatRoomId(_auth.currentUser!.displayName!, UserMap!['name']);

              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatRoom(chatRommId: roomId, UserMap: UserMap!)));
            },

            leading: Icon(Icons.account_box , color: Colors.black),
            title: Text(
              UserMap!['name'],
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(UserMap!['email']),
            trailing: Icon(Icons.chat, color: Colors.black),
          )
          :Container(),


          
        ],
      ),

      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GroupChatHomeScreen(),))),
    );
  }
}