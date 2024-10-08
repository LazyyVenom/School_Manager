import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/chat/chat_services.dart';
import 'package:intl/intl.dart';

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
  void initState() {
    super.initState();

    // Mark all messages as read when this chat page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
      _chatService.markMessagesAsRead(currentUser.gmail!, widget.email);
    });
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    // Stream of messages between the current user and the recipient
    Stream<List<Message>> messageStream = _chatService.getMessages(currentUser.gmail!, widget.email);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.type}"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: messageStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages found'));
                }

                var messages = snapshot.data!;

                return ListView.builder(
                  itemCount: messages.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    var isCurrentUser = message.senderEmail == currentUser.gmail;
                    var isNew = message.isNew;

                    return _buildMessageBubble(
                      message.message,
                      isCurrentUser,
                      message.timestamp.toDate(),
                      isNew,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(currentUser),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isCurrentUser, DateTime? timestamp, bool isNew) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: isCurrentUser
                ? Colors.deepPurple[100]
                : isNew
                    ? Colors.orange[200] // Highlight new messages with a different color
                    : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isCurrentUser ? 12 : 0),
              topRight: Radius.circular(isCurrentUser ? 0 : 12),
              bottomLeft: const Radius.circular(12),
              bottomRight: const Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              if (timestamp != null) ...[
                const SizedBox(height: 4),
                Text(
                  DateFormat('hh:mm a').format(timestamp),
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(CurrentUser currentUser) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  await _chatService.sendMessage(
                    currentUser.gmail!, // Sender
                    widget.email,       // Receiver
                    _controller.text,   // Message
                  );
                  _controller.clear(); // Clear the text field
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
