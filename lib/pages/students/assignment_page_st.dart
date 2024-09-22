import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/assignment_service.dart';
import 'package:school_manager/pages/students/assignment_details.dart';
import 'package:school_manager/pages/teacher/assignment_helper_page.dart';

class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  final List<String> categories = ['All', 'Assignment', 'Homework'];
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
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 6),
              Text(
                "Assignments",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = categories[index];
                          });
                        },
                        child: Chip(
                          label: Text(categories[index]),
                          labelStyle: TextStyle(
                            color: selectedCategory == categories[index]
                                ? Colors.white
                                : Colors.deepPurple,
                          ),
                          backgroundColor: selectedCategory == categories[index]
                              ? Colors.deepPurple
                              : Colors.deepPurple[50],
                          shape: const StadiumBorder(
                            side: BorderSide(
                              color: Colors.deepPurple,
                              width: 1.5,
                            ),
                          ),
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
                        if (selectedCategory == 'All' ||
                            assignment['type'] == selectedCategory) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: Icon(
                                  Icons.bookmark,
                                  color: Colors.deepPurple[300],
                                ),
                                title: Text(
                                  assignment['assignment'] ?? 'No Title',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Due Date: ${assignment['dueDate']?.toDate().toLocal()}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.deepPurple[300],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AssignmentDetailPage(
                                        assignmentData: assignment.data()
                                            as Map<String, dynamic>, // Pass the assignment data
                                      ),
                                    ),
                                  );
                                },
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
          // Floating action button to add a new assignment
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                // Navigate to a page for adding assignments
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAssignmentPage(),
                  ),
                );
              },
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
