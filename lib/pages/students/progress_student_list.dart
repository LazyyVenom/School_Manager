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
  List<String> _classList = [];
  List<String> _sectionList = [];
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchClassesAndSections();
  }

  Future<void> _fetchClassesAndSections() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch classes and their sections from Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc('School')
          .get();
      
      _classList = List<String>.from(snapshot.data()?['classes'] ?? []);
      _sectionList = List<String>.from(snapshot.data()?['sections'] ?? []);
      
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching classes and sections: $e"),
          backgroundColor: Colors.red[200],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              items: _selectedClass != null
                  ? _sectionList.map((sectionItem) {
                      return DropdownMenuItem<String>(
                        value: sectionItem,
                        child: Text(sectionItem),
                      );
                    }).toList()
                  : [],
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
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              student['studentName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              "ID: ${student['studentId']}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                            onTap: () {
                              // Navigate to DisplayStudentProgress page with student data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DisplayStudentProgress(
                                    studentEmail: student['studentId'], // Assuming studentId is their email
                                    className: _selectedClass!,
                                    sectionName: _selectedSection!,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
