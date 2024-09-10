import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';

class ChatPage extends StatefulWidget {
  // Use an initializer list to assign the value of 'type'
  const ChatPage({super.key, required this.type});

  final String type;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Widget _buildUserList(DocumentSnapshot document, CurrentUser currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Got Some Error While Loading List');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc, currentUser))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
      DocumentSnapshot document, CurrentUser currentUser) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (currentUser.gmail != data['email']) {
      return ListTile(
        title: data['email'],
        onTap: () {
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ChatPage(type: 'Raj'))
          );
        },
      );
    }
    else {
      return const Placeholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose A Chat'),
      ),
      body: _buildUserList(document, currentUser),
    );
  }
}
