import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
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

  @override
  void dispose() {
    assignmentTitleController.dispose();
    assignmentDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context, listen: false);
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
              // TextField for Notification Title
              TextField(
                controller: assignmentTitleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Assignment Title',
                ),
              ),
              const SizedBox(height: 10),
              // TextField for Notification Details
              TextField(
                controller: assignmentDetailController,
                maxLines: 4, // Bigger box for details
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Details',
                ),
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
              const SizedBox(height: 20),
              // Button to submit
              ElevatedButton(
                onPressed: () {
                  if (assignmentTitleController.text.isNotEmpty &&
                      assignmentDetailController.text.isNotEmpty) {
                    // Call your assignment service to add the assignment
                    assignmentService.addAssignment(
                      currentUser.className!,
                      currentUser.section!,
                      assignmentTitleController.text,
                      assignmentDetailController.text,
                      selectedType,
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
