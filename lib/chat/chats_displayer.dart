import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.type});

  final String type;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Method to build the user list from Firestore
  Widget _buildUserList(CurrentUser currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading users.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            return _buildUserListItem(document, currentUser);
          }).toList(),
        );
      },
    );
  }

  // Method to build each user list item
  Widget _buildUserListItem(DocumentSnapshot document, CurrentUser currentUser) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // Exclude current user from the list
    if (currentUser.gmail != data['email']) {
      return ListTile(
        title: Text(data['email'] ?? 'Unknown User'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                type: data['email'], 
              ),
            ),
          );
        },
      );
    } else {
      return const SizedBox.shrink(); // Skip the current user
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user from the Provider
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose A Chat'),
      ),
      body: _buildUserList(currentUser), // Load the user list
    );
  }
}
