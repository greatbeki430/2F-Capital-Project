import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Todo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
      ),
    );
  }
}