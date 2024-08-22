import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
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
                      _controller.clear(); // Clear the input after sending
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
