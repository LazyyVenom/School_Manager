import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart'; // For file names
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/chat/chat_services.dart';

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
  final ImagePicker _picker = ImagePicker();
  File? _imageFile; // File to store selected image

  // Method to upload image and send the message
  Future<void> _sendImageMessage(String currentUserEmail) async {
    if (_imageFile == null) return;

    try {
      String fileName = basename(_imageFile!.path); // Get file name
      Reference storageRef =
          FirebaseStorage.instance.ref().child('chat_images/$fileName');

      // Upload image to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(_imageFile!);
      await uploadTask;

      // Get the download URL for the uploaded image
      String imageUrl = await storageRef.getDownloadURL();

      // Send the image message using the ChatService
      await _chatService.sendImageMessage(
        currentUserEmail,
        widget.email,
        imageUrl, // Send the image URL instead
      );
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      setState(() {
        _imageFile = null; // Clear the image file after sending
      });
    }
  }

  // Method to pick image from the gallery
  Future<void> _pickImageFromGallery(String currentUserEmail) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _sendImageMessage(currentUserEmail); // Send image after picking
    }
  }

  // Method to capture image using camera
  Future<void> _captureImageWithCamera(String currentUserEmail) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _sendImageMessage(currentUserEmail); // Send image after capturing
    }
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    // Stream of messages between the current user and the recipient
    Stream<QuerySnapshot> messageStream = _chatService.getMessages(
      currentUser.gmail!,
      widget.email,
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
                  reverse: true, // Show latest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData =
                        messages[index].data() as Map<String, dynamic>;
                    var isCurrentUser =
                        messageData['senderEmail'] == currentUser.gmail;

                    // Check if the message is an image or text
                    bool isImageMessage = messageData['isImage'] ?? false;

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
                          child: isImageMessage
                              ? Image.network(
                                  messageData['content'], // Display the image
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                              : Text(messageData['content'] ??
                                  ''), // Display text message
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
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.deepPurple),
                  onPressed: () => _captureImageWithCamera(
                      currentUser.gmail!), // Capture image with camera
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.deepPurple),
                  onPressed: () => _pickImageFromGallery(
                      currentUser.gmail!), // Pick image from gallery
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
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
                      // Send the text message using ChatService
                      await _chatService.sendTextMessage(
                        currentUser.gmail!, // Sender
                        widget.email, // Receiver
                        _controller.text, // Message
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
