import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Assignment {
  final String classRec;
  final String section;
  final String assignment;
  final Timestamp timestamp;
  final String details;
  final String type;
  final Timestamp dueDate; // New field for due date

  Assignment({
    required this.classRec,
    required this.section,
    required this.timestamp,
    required this.assignment,
    required this.details,
    required this.type,
    required this.dueDate, // Include new parameter in constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'classRec': classRec,
      'section': section,
      'timestamp': timestamp,
      'assignment': assignment,
      'details': details,
      'type': type,
      'dueDate': dueDate, // Include due date in map
    };
  }
}

class AssignmentService extends ChangeNotifier {
  // Get Instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Assignments
  Future<void> addAssignment(
      String classRec,
      String mySection,
      String assignment,
      String details,
      String type,
      DateTime dueDate) async { // Accept due date
    final timestamp = Timestamp.now();

    Assignment newAssignment = Assignment(
      classRec: classRec,
      section: mySection,
      timestamp: timestamp,
      assignment: assignment,
      details: details,
      type: type,
      dueDate: Timestamp.fromDate(dueDate), // Convert to Timestamp
    );

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
