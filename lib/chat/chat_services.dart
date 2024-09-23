import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String senderEmail;
  final String receiverEmail;
  final String message;
  final Timestamp timestamp;
  bool isNew;

  Message({
    required this.senderEmail,
    required this.receiverEmail,
    required this.timestamp,
    required this.message,
    this.isNew = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'timestamp': timestamp,
      'message': message,
      'is_new': isNew,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderEmail: map['senderEmail'],
      receiverEmail: map['receiverEmail'],
      timestamp: map['timestamp'],
      message: map['message'],
      isNew: map['is_new'],
    );
  }
}

class ChatService extends ChangeNotifier {
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

    // Add message to the messages array in the chat room document
    await _firestore.collection('chat_rooms').doc(chatRoomID).set(
      {
        'messages': FieldValue.arrayUnion([newMessage.toMap()]),
      },
      SetOptions(merge: true), // Merge with existing data
    );
  }

  // Get Messages Stream
  Stream<List<Message>> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore.collection('chat_rooms').doc(chatRoomID).snapshots().map(
      (docSnapshot) {
        if (docSnapshot.exists && docSnapshot.data() != null) {
          // Cast the data to a Map<String, dynamic>
          Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
          List<dynamic> messageMaps = data['messages'] ?? [];
          return messageMaps.map((map) => Message.fromMap(map)).toList();
        }
        return [];
      },
    );
  }

  // Mark all messages as read when the user views the chat
  Future<void> markMessagesAsRead(String userId, String otherUserId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Fetch the chat room document
    DocumentSnapshot chatRoomDoc = await _firestore.collection('chat_rooms').doc(chatRoomID).get();
    if (chatRoomDoc.exists && chatRoomDoc.data() != null) {
      // Cast the data to a Map<String, dynamic>
      Map<String, dynamic> data = chatRoomDoc.data() as Map<String, dynamic>;
      List<dynamic> messages = data['messages'] ?? [];

      for (var message in messages) {
        if (message['receiverEmail'] == userId && message['is_new'] == true) {
          // Update the is_new flag in the message
          message['is_new'] = false; // Mark as read
        }
      }

      // Update the messages array in Firestore
      await _firestore.collection('chat_rooms').doc(chatRoomID).update({
        'messages': messages,
      });
    }
  }
}
