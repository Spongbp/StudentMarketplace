import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart'; // Import the chat screen

class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.lightGreen,
      ),
      body: currentUser == null
          ? Center(child: Text('Please log in to view your messages.'))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participants', arrayContains: currentUser.uid)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading conversations.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final conversations = snapshot.data?.docs ?? [];
          if (conversations.isEmpty) {
            return Center(child: Text('No conversations found.'));
          }
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final data = conversation.data() as Map<String, dynamic>;
              final participants = data['participants'] as List<dynamic>;
              final otherUserId = participants.firstWhere(
                      (participant) => participant != currentUser.uid);

              // Check if there are unread messages for current user
              final List<dynamic>? unreadBy = data['unreadBy'];
              final bool hasUnreadMessages = unreadBy != null &&
                  unreadBy.contains(currentUser.uid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  }
                  final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
                  final userName = userData['name'] ?? 'User';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                      userData['profilePictureUrl'] != null
                          ? NetworkImage(
                          userData['profilePictureUrl'])
                          : null,
                      child: userData['profilePictureUrl'] == null
                          ? Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      userName,
                      style: TextStyle(
                        fontWeight: hasUnreadMessages
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      data['lastMessage'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: hasUnreadMessages
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            conversationId: conversation.id,
                            otherUserId: otherUserId,
                            otherUserName: userName,
                            otherUserProfilePic:
                            userData['profilePictureUrl'],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}