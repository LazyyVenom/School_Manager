import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Assignment {
  final String classRec;
  final String assignment;
  final Timestamp timestamp;
  final String details;

  Assignment({
    required this.classRec,
    required this.timestamp,
    required this.assignment,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'classRec': classRec,
      'timestamp': timestamp,
      'assignment': assignment,
      'details': details,
    };
  }
}

class AssignmentService extends ChangeNotifier {
  // Get Instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Assignments
  Future<void> addAssignment(
      String classRec, String mySection, String assignment, String details) async {
    final timestamp = Timestamp.now();

    Assignment newAssignment = Assignment(
        classRec: classRec, timestamp: timestamp, assignment: assignment, details: details);

    await _firestore
        .collection('alerts')
        .doc("$classRec$mySection")
        .collection('assignments')
        .add(newAssignment.toMap());
  }

  // Get Assignments
  Stream<QuerySnapshot> getAssignments(String myClass, String mySection) {
    return _firestore
        .collection('alerts')
        .doc("$myClass$mySection")
        .collection('assignments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
