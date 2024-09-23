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
  Future<List<Map<String, dynamic>>> _fetchUnreadMessages(CurrentUser currentUser) async {
    Set<String> uniqueSenders = {};

    var chatRoomsSnapshot = await FirebaseFirestore.instance.collection('chat_rooms').get();
    List<Map<String, dynamic>> unreadMessagesList = [];

    for (var doc in chatRoomsSnapshot.docs) {
      String chatRoomId = doc.id;
      var messages = doc['messages'] as List<dynamic>?;

      if (messages != null && messages.isNotEmpty) {
        var lastMessage = messages.last;

        if (lastMessage['is_new'] == true && lastMessage['receiverEmail'] == currentUser.gmail) {
          uniqueSenders.add(lastMessage['senderEmail']);
          unreadMessagesList.add({
            'otherUserEmail': lastMessage['senderEmail'],
            'chatRoomId': chatRoomId,
          });
        }
      }
    }

    return unreadMessagesList;
  }

  Widget _buildChatList(CurrentUser currentUser) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchUnreadMessages(currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading chats.'));
        }

        final unreadMessagesList = snapshot.data ?? [];

        return ListView.separated(
          itemCount: unreadMessagesList.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final chatInfo = unreadMessagesList[index];
            return _buildChatListItem(chatInfo['otherUserEmail'], chatInfo['chatRoomId'], currentUser);
          },
        );
      },
    );
  }

  Widget _buildChatListItem(String otherUserEmail, String chatRoomId, CurrentUser currentUser) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        tileColor: Colors.deepPurple[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple[100],
          child: Icon(
            Icons.chat,
            color: Colors.deepPurple[400],
          ),
        ),
        title: Text(
          otherUserEmail,
          style: Theme.of(context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
        ),
        subtitle: Text(
          'You have unread messages',
          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.grey[600]),
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

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildChatList(currentUser),
    );
  }
}
