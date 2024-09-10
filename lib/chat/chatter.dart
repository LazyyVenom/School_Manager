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
  // Sample list of messages
  final List<String> messages = [
    "Hello!",
    "How are you?",
    "I'm learning Flutter.",
    "This is a scrollable chat interface.",
    "What are you working on?",
    "Let's build something cool!",
  ];

  // Controller to handle the input text
  final TextEditingController _controller = TextEditingController();

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
        onTap: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Messaging ${widget.type}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Align(
                    alignment: index % 2 == 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? Colors.grey[300]
                            : Colors.deepPurple[100],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(messages[index]),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.deepPurple,
                  ),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      // Sending Logic Here
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
