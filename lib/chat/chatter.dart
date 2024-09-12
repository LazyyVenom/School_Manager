import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/chat/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.type, required this.email});

  final String type;
  final String email;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    // Stream of messages between the current user and the recipient
    Stream<QuerySnapshot> messageStream = _chatService.getMessages(
      currentUser.gmail!, widget.email,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Messaging ${widget.type}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messageStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Get the list of messages from Firestore
                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index].data() as Map<String, dynamic>;
                    var isCurrentUser = messageData['senderEmail'] == currentUser.gmail;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Colors.deepPurple[100]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(messageData['message']),
                        ),
                      ),
                    );
                  },
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
                  onPressed: () async {
                    if (_controller.text.isNotEmpty) {
                      // Send the message using ChatService
                      await _chatService.sendMessage(
                        currentUser.gmail!, // Sender
                        widget.email,       // Receiver
                        _controller.text,   // Message
                      );
                      _controller.clear(); // Clear the text field
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
