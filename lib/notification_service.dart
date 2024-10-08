import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Notification {
  final String classRec;
  final String notification;
  final Timestamp timestamp;

  Notification({
    required this.classRec,
    required this.timestamp,
    required this.notification,
  });

  Map<String, dynamic> toMap() {
    return {
      'classRec': classRec,
      'timestamp': timestamp,
      'notification': notification,
    };
  }
}

class NotificationService extends ChangeNotifier {
  // Get Instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SEND notification
  Future<void> sendNotification(
      String classRec, String mySection, String notification) async {
    final timestamp = Timestamp.now();

    Notification newNotification = Notification(
        classRec: classRec, timestamp: timestamp, notification: notification);

    await _firestore
        .collection('alerts')
        .doc("$classRec$mySection")
        .collection('notifications')
        .add(newNotification.toMap());
  }

  // Get notifications
  Stream<QuerySnapshot> getNotifications(String myClass, String mySection) {
    return _firestore
        .collection('alerts')
        .doc("$myClass$mySection")
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteNotification(String docId, String docName) async {
    await _firestore
        .collection('alerts')
        .doc(docName)
        .collection('notifications')
        .doc(docId)
        .delete();
  }
}
