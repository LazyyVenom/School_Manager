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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildUserListItem(
      DocumentSnapshot document, CurrentUser currentUser) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (widget.type.toLowerCase() == 'management') {
      if ((currentUser.gmail != data['email']) &
          (widget.type.toLowerCase().contains(data['role']))) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    type: data['name'],
                    email: data['email'],
                  ),
                ),
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple[100],
                radius: 24,
                child: Icon(
                  Icons.person,
                  color: Colors.deepPurple[400],
                  size: 30,
                ),
              ),
              title: Text(
                data['name'] ?? 'Unknown User',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple[800],
                    ),
              ),
              subtitle: Text(
                data['email'] ?? 'Role: Unknown',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.deepPurple[300],
                    ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.deepPurple[400],
                size: 18,
              ),
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      if ((currentUser.gmail != data['email']) &
          (widget.type.toLowerCase().contains(data['role'])) &
          (data['class'] == currentUser.className) & 
          (data['section'] == currentUser.section)) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    type: data['name'],
                    email: data['email'],
                  ),
                ),
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple[100],
                radius: 24,
                child: Icon(
                  Icons.person,
                  color: Colors.deepPurple[400],
                  size: 30,
                ),
              ),
              title: Text(
                data['name'] ?? 'Unknown User',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple[800],
                    ),
              ),
              subtitle: Text(
                data['email'] ?? 'Role: Unknown',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.deepPurple[300],
                    ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.deepPurple[400],
                size: 18,
              ),
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact ${widget.type}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Add search functionality later
            },
          ),
        ],
      ),
      body: _buildUserList(currentUser),
    );
  }
}
