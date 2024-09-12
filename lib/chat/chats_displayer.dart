import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/chat/chatter.dart';

class ChatsDisplay extends StatefulWidget {
  const ChatsDisplay({super.key, required this.type});

  final String type;

  @override
  State<ChatsDisplay> createState() => _ChatsDisplayState();
}

class _ChatsDisplayState extends State<ChatsDisplay> {
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
            return Padding(
              padding: const EdgeInsets.only(top: 3),
              child: _buildUserListItem(document, currentUser),
            );
          }).toList(),
        );
      },
    );
  }

  // Method to build each user list item
  Widget _buildUserListItem(
      DocumentSnapshot document, CurrentUser currentUser) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // Exclude current user from the list

    if ((currentUser.gmail != data['email']) & (widget.type.toLowerCase().contains(data['role']))) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          tileColor: Colors.deepPurple[50],
          contentPadding:
              const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple[100],
            child: Icon(
              Icons.person,
              color: Colors.deepPurple[400],
            ),
          ),
          title: Text(
            data['name'] ?? 'Unknown User',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            data['email'] ?? 'Role: Unknown', // Example additional data
            style: Theme.of(context).textTheme.bodyMedium,
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
                  type: data['name'], // Pass user email to ChatsDisplay
                ),
              ),
            );
          },
        ),
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
        title: Text('Contact ${widget.type}'),
      ),
      body: _buildUserList(currentUser), // Load the user list
    );
  }
}
