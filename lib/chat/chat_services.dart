import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String senderEmail;
  final String receiverEmail;
  final String message;
  final Timestamp timestamp;
  bool isNew; // Add is_new flag

  Message({
    required this.senderEmail,
    required this.receiverEmail,
    required this.timestamp,
    required this.message,
    this.isNew = true, // Set default as true when a message is created
  });

  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'timestamp': timestamp,
      'message': message,
      'is_new': isNew, // Add is_new field to Firestore
    };
  }

  // Factory method to convert Firestore document into Message object
  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      senderEmail: doc['senderEmail'],
      receiverEmail: doc['receiverEmail'],
      timestamp: doc['timestamp'],
      message: doc['message'],
      isNew: doc['is_new'], // Read is_new flag from Firestore
    );
  }
}

class ChatService extends ChangeNotifier {
  // Get instance of Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send Message
  Future<void> sendMessage(
      String senderEmail, String receiverEmail, String message) async {
    final timestamp = Timestamp.now();

    Message newMessage = Message(
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      timestamp: timestamp,
      message: message,
    );

    List<String> ids = [senderEmail, receiverEmail];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // Get Messages Stream
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Mark all messages as read when the user views the chat
  Future<void> markMessagesAsRead(String userId, String otherUserId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    QuerySnapshot unreadMessages = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .where('receiverEmail', isEqualTo: userId) // Only update messages for the receiver
        .where('is_new', isEqualTo: true) // Only mark unread messages
        .get();

    for (var doc in unreadMessages.docs) {
      await doc.reference.update({'is_new': false}); // Mark message as read
    }
  }
}
