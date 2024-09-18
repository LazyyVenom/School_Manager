import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String senderEmail;
  final String receiverEmail;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderEmail,
    required this.receiverEmail,
    required this.timestamp,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'timestamp': timestamp,
      'message': message,
    };
  }
}

class ChatService extends ChangeNotifier {
  // Get Instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SEND MESSAGE
  Future<void> sendMessage(
      String senderEmail, String receiverEmail, String message) async {
    final timestamp = Timestamp.now();

    Message newMessage = Message(
        senderEmail: senderEmail,
        receiverEmail: receiverEmail,
        timestamp: timestamp,
        message: message);

    List<String> ids = [senderEmail, receiverEmail];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // Get Messages
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
}
