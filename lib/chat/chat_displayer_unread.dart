import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/chat/chatter.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  Widget _buildChatList(CurrentUser currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chat_rooms').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading chats.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Collect all chat rooms that contain the current user
        final chatRooms = snapshot.data!.docs.where((document) {
          return (document['participants'] as List<dynamic>).contains(currentUser.gmail);
        }).toList();

        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            return _buildChatListItem(chatRoom, currentUser);
          },
        );
      },
    );
  }

  Future<bool> _hasUnreadMessages(String chatRoomId, String currentUserEmail) async {
    // Access the messages array in this chat room document
    final chatRoomSnapshot = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .get();

    var messages = chatRoomSnapshot['messages'] as List<dynamic>?;

    // Check if the messages array is not null and contains unread messages for the current user
    if (messages != null) {
      return messages.any((message) =>
          message['is_new'] == true && message['receiverEmail'] == currentUserEmail);
    }

    return false; // No unread messages
  }

  Widget _buildChatListItem(DocumentSnapshot document, CurrentUser currentUser) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // Assuming the other user's email can be fetched from participants
    String otherUserEmail = (data['participants'] as List<dynamic>).firstWhere(
      (email) => email != currentUser.gmail,
    );

    return FutureBuilder<bool>(
      future: _hasUnreadMessages(document.id, currentUser.gmail!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // or a loading indicator
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink(); // handle error as needed
        }

        // Only show the chat if there are unread messages
        if (snapshot.data == true) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              tileColor: Colors.deepPurple[50],
              contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple[100],
                child: Icon(
                  Icons.chat,
                  color: Colors.deepPurple[400],
                ),
              ),
              title: Text(
                otherUserEmail,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.deepPurple[400],
                size: 20,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      type: 'Chat with $otherUserEmail',
                      email: otherUserEmail,
                    ),
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink(); // Hide chat if no unread messages
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _buildChatList(currentUser),
    );
  }
}
