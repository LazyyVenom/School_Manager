import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/pages/teacher/show_progress.dart';

class StudentListPage extends StatefulWidget {
  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  String? _selectedClass;
  String? _selectedSection;
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = false;

  // Dummy data for dropdowns (can be replaced with Firestore query results)
  List<String> _classList = ['Class 1', 'Class 2', 'Class 3'];
  List<String> _sectionList = ['A', 'B', 'C'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Class and Section"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown for Class Selection
            DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: const InputDecoration(
                labelText: "Select Class",
                border: OutlineInputBorder(),
              ),
              items: _classList.map((classItem) {
                return DropdownMenuItem<String>(
                  value: classItem,
                  child: Text(classItem),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClass = value;
                  _fetchStudents(); // Fetch students when class is changed
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Dropdown for Section Selection
            DropdownButtonFormField<String>(
              value: _selectedSection,
              decoration: const InputDecoration(
                labelText: "Select Section",
                border: OutlineInputBorder(),
              ),
              items: _sectionList.map((sectionItem) {
                return DropdownMenuItem<String>(
                  value: sectionItem,
                  child: Text(sectionItem),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSection = value;
                  _fetchStudents(); // Fetch students when section is changed
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Display list of students
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return ListTile(
                          title: Text(student['studentName']),
                          onTap: () {
                            // Navigate to DisplayStudentProgress page with student data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DisplayStudentProgress(
                                  studentName: student['studentName'],
                                  className: _selectedClass!,
                                  sectionName: _selectedSection!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchStudents() async {
    if (_selectedClass == null || _selectedSection == null) return;

    setState(() {
      _isLoading = true;
      _students.clear();
    });

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'student')
              .where('class', isEqualTo: _selectedClass)
              .where('section', isEqualTo: _selectedSection)
              .get();

      List<Map<String, dynamic>> studentList = querySnapshot.docs.map((doc) {
        return {
          'studentName': doc.data()['name'],
          'studentId': doc.id,
        };
      }).toList();

      setState(() {
        _students = studentList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching students: $e"),
          backgroundColor: Colors.red[200],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}