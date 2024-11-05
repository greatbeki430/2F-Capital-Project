import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_chat_app/pages/chat_room.dart';
import 'package:todo_chat_app/pages/login.dart';
import 'package:todo_chat_app/pages/todo_rom.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _children;

  _HomePageState()
      : _children = [
          // There are two tabs/or Bottom nav bars as in the instruction or assessment,
          TodoRoom(),
          const ChatRoom(
            chatRoomId:
                'example_chat_room_id', 
            isGroupChat: false, 
          ),
        ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Todo & Chat App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.blue, 
        selectedItemColor: Colors.white, 
        unselectedItemColor: const Color.fromARGB(
            255, 16, 209, 29), 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
