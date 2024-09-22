import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart'; // Ensure this imports CurrentUser
import 'package:school_manager/assignment_service.dart';
import 'package:school_manager/pages/students/assignment_details.dart'; // Import your assignment details page
import 'package:school_manager/pages/teacher/assignment_helper_page.dart';

class AssignmentPageTh extends StatefulWidget {
  const AssignmentPageTh({super.key});

  @override
  State<AssignmentPageTh> createState() => _AssignmentPageThState();
}

class _AssignmentPageThState extends State<AssignmentPageTh> {
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
              // Category selector UI
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
                            // Debug print to check selected category
                            print("Selected Category: $selectedCategory");
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
              // Assignment List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: assignmentService.getAssignments(
                    currentUser.className!,
                    currentUser.section!,
                  ),
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
                        var assignmentType = assignment['type'];

                        // Debug print to check assignment type and filtering logic
                        print("Assignment Type: $assignmentType");

                        // Filter based on the selected category
                        if (selectedCategory == 'All' ||
                            assignmentType == selectedCategory) {
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
                                  // Navigate to the assignment detail page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AssignmentDetailPage(
                                        assignmentData: assignment.data()
                                            as Map<String, dynamic>,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink(); // Return an empty widget if not displayed
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
