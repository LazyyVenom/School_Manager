import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_manager/assignment_service.dart';

class AddAssignmentPage extends StatefulWidget {
  @override
  _AddAssignmentPageState createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  final assignmentDetailController = TextEditingController();
  final assignmentTitleController = TextEditingController();
  final assignmentService = AssignmentService();
  
  String selectedType = 'Assignment';
  String? selectedClass;
  String? selectedSection;
  DateTime? selectedDate;
  
  List<String> _classes = [];
  List<String> _sections = [];

  @override
  void initState() {
    super.initState();
    _fetchClassesAndSections();
  }

  Future<void> _fetchClassesAndSections() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('classes')
        .doc('School')
        .get();

    if (snapshot.exists) {
      setState(() {
        _classes = List<String>.from(snapshot.data()?['classes'] ?? []);
        _sections = List<String>.from(snapshot.data()?['sections'] ?? []);
      });
    }
  }

  @override
  void dispose() {
    assignmentTitleController.dispose();
    assignmentDetailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // TextField for Assignment Title
              TextField(
                controller: assignmentTitleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Assignment Title',
                ),
              ),
              const SizedBox(height: 10),
              // TextField for Assignment Details
              TextField(
                controller: assignmentDetailController,
                maxLines: 4, // Bigger box for details
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Details',
                ),
              ),
              const SizedBox(height: 10),
              // DropdownButton for Class
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select Class',
                ),
                items: _classes.map((className) {
                  return DropdownMenuItem<String>(
                    value: className,
                    child: Text(className),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedClass = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),
              // DropdownButton for Section
              DropdownButtonFormField<String>(
                value: selectedSection,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select Section',
                ),
                items: _sections.map((sectionName) {
                  return DropdownMenuItem<String>(
                    value: sectionName,
                    child: Text(sectionName),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedSection = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),
              // DropdownButton for Homework/Assignment
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select Type',
                ),
                items: <String>['Homework', 'Assignment'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),
              // DatePicker for Due Date
              Row(
                children: [
                  Text(selectedDate == null
                      ? 'No date selected!'
                      : 'Due Date: ${selectedDate!.toLocal()}'.split(' ')[0]),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Due Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Button to submit
              ElevatedButton(
                onPressed: () {
                  if (assignmentTitleController.text.isNotEmpty &&
                      assignmentDetailController.text.isNotEmpty &&
                      selectedClass != null &&
                      selectedSection != null &&
                      selectedDate != null) {
                    // Call your assignment service to add the assignment
                    assignmentService.addAssignment(
                      selectedClass!,
                      selectedSection!,
                      assignmentTitleController.text,
                      assignmentDetailController.text,
                      selectedType,
                      selectedDate!,
                    );
                    Navigator.of(context).pop(); // Go back after adding
                    assignmentTitleController.clear();
                    assignmentDetailController.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter all details'),
                      ),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
