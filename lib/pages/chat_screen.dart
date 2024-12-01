// lib/pages/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserProfilePic;

  ChatScreen({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserProfilePic,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _markMessagesAsRead();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (currentUser != null) {
      _markMessagesAsRead();
    }
  }

  // method to mark messages as read
  void _markMessagesAsRead() async {
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .update({
      'unreadBy': FieldValue.arrayRemove([currentUser!.uid]),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
          backgroundColor: Colors.lightGreen,
        ),
        body: Center(child: Text('Please log in to chat.')),
      );
    }

    // Added check for empty conversationId
    if (widget.conversationId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
          backgroundColor: Colors.lightGreen,
        ),
        body: Center(child: Text('Invalid conversation ID.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUserProfilePic != null
                  ? NetworkImage(widget.otherUserProfilePic!)
                  : null,
              child: widget.otherUserProfilePic == null
                  ? Icon(Icons.person)
                  : null,
            ),
            SizedBox(width: 8),
            Text(widget.otherUserName),
          ],
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(widget.conversationId)
                  .collection('messages')
                  .orderBy('sentAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading messages.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data?.docs ?? [];
                if (messages.isEmpty) {
                  return Center(child: Text('Start the conversation!'));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                    messages[index].data() as Map<String, dynamic>;
                    final isMe = messageData['senderId'] == currentUser!.uid;
                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(messageData['text'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.green),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (currentUser == null) return; // Check for current user being null

    final messageText = _messageController.text.trim();
    _messageController.clear();

    final messageData = {
      'text': messageText,
      'senderId': currentUser!.uid,
      'receiverId': widget.otherUserId,
      'sentAt': FieldValue.serverTimestamp(),
    };

    final conversationRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId);

    await conversationRef.collection('messages').add(messageData);

    // Update last message info and unreadBy in conversation
    await conversationRef.update({
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadBy': FieldValue.arrayUnion([widget.otherUserId]),
    });
  }
}