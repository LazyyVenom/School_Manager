import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String senderEmail;
  final String receiverEmail;
  final String content; // Can be text or image URL
  final Timestamp timestamp;
  final bool isImage; // Flag to indicate if the message is an image

  Message({
    required this.senderEmail,
    required this.receiverEmail,
    required this.timestamp,
    required this.content,
    this.isImage = false,
  });

  // Convert message object to a map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'timestamp': timestamp,
      'content': content,
      'isImage': isImage, // Store if the message is an image
    };
  }
}

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sends a text message between users
  Future<void> sendTextMessage(
      String senderEmail, String receiverEmail, String messageText) async {
    final timestamp = Timestamp.now();

    Message newMessage = Message(
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      timestamp: timestamp,
      content: messageText,
    );

    // Create chat room ID based on sorted email addresses
    String chatRoomID = _createChatRoomID(senderEmail, receiverEmail);

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // Sends an image message between users
  Future<void> sendImageMessage(
      String senderEmail, String receiverEmail, String imageUrl) async {
    final timestamp = Timestamp.now();

    Message newMessage = Message(
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      timestamp: timestamp,
      content: imageUrl,
      isImage: true, // Indicate this message is an image
    );

    String chatRoomID = _createChatRoomID(senderEmail, receiverEmail);

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // Creates a chat room ID using the emails of both users
  String _createChatRoomID(String user1, String user2) {
    List<String> ids = [user1, user2];
    ids.sort(); // Ensure chat room ID is always in the same order
    return ids.join('_');
  }

  // Retrieves a stream of messages between the current user and another user
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    String chatRoomID = _createChatRoomID(userId, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
