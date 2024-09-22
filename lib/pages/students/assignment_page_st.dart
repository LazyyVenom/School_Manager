import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart'; // Import CurrentUser model
import 'package:school_manager/assignment_service.dart'; // Import your AssignmentService

class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  final List<String> categories = ['All', 'Assignments', 'Homework'];
  String selectedCategory = 'All';
  late AssignmentService assignmentService;

  @override
  void initState() {
    super.initState();
    assignmentService = AssignmentService(); // Initialize assignment service
  }

  @override
  Widget build(BuildContext context) {
    // Get current user information from Provider
    final currentUser = Provider.of<CurrentUser>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Text(
            "Assignments",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 6),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = categories[index];
                      });
                    },
                    child: Chip(
                      label: Text(categories[index]),
                      backgroundColor: selectedCategory == categories[index]
                          ? Colors.deepPurple[200]
                          : Colors.deepPurple[50],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 6),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: assignmentService.getAssignments(
                currentUser.className!,
                currentUser.section!,
              ), // Get assignments for the user's class and section
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No assignments found'));
                }

                final assignments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    var assignment = assignments[index];
                    // Filter based on the selected category
                    if (selectedCategory == 'All' ||
                        assignment['type'] == selectedCategory) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          color: Colors.deepPurple[50],
                          child: ListTile(
                            leading: Icon(
                              Icons.bookmark,
                              color: Colors.deepPurple[300],
                            ),
                            title: Text(assignment['assignment'] ?? 'No Title'),
                            subtitle: Text(
                              "Due Date: ${assignment['dueDate']?.toDate().toLocal()}",
                            ),
                            trailing: Icon(
                              Icons.arrow_circle_right,
                              color: Colors.deepPurple[300],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink(); // If not in selected category, return an empty widget
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
