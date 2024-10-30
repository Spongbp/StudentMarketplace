import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          '0 conversations started',
          style: TextStyle(
              fontSize: 18,
              color: Colors.grey
          ),
        ),
      ),
    );
  }
}
