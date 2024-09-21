import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/pages/teacher/add_marks.dart';

class AddStudentMarksPage extends StatefulWidget {
  const AddStudentMarksPage({super.key});

  @override
  State<AddStudentMarksPage> createState() => _AddStudentMarksPageState();
}

class _AddStudentMarksPageState extends State<AddStudentMarksPage> {
  String? _selectedClass;
  String? _selectedSection;
  List<String> _classes = [];
  List<String> _sections = [];
  List<String> _students = [];
  bool _isLoadingStudents = false;

  @override
  void initState() {
    super.initState();
    _fetchClassesAndSections();
  }

  Future<void> _fetchClassesAndSections() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('classes')
          .doc('School')
          .get();

      List<String> classList = List<String>.from(snapshot.data()?['classes'] ?? []);
      List<String> sectionList = List<String>.from(snapshot.data()?['sections'] ?? []);

      setState(() {
        _classes = classList;
        _sections = sectionList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error fetching classes and sections: $e",
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.red[200],
        ),
      );
    }
  }

  Future<void> _fetchStudents() async {
    if (_selectedClass == null || _selectedSection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please select class and section",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.red[200],
        ),
      );
      return;
    }

    setState(() {
      _isLoadingStudents = true;
    });

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('class', isEqualTo: _selectedClass)
          .where('section', isEqualTo: _selectedSection)
          .get();

      List<String> studentList = snapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        _students = studentList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error fetching students: $e",
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.red[200],
        ),
      );
    } finally {
      setState(() {
        _isLoadingStudents = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Student Marks"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: const InputDecoration(
                labelText: "Select Class",
                border: OutlineInputBorder(),
              ),
              items: _classes.map((className) {
                return DropdownMenuItem(
                  value: className,
                  child: Text(className),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClass = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSection,
              decoration: const InputDecoration(
                labelText: "Select Section",
                border: OutlineInputBorder(),
              ),
              items: _sections.map((sectionName) {
                return DropdownMenuItem(
                  value: sectionName,
                  child: Text(sectionName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSection = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchStudents,
              child: _isLoadingStudents
                  ? const CircularProgressIndicator()
                  : const Text("Fetch Students"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_students[index]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMarksPage(
                            // studentName: _students[index],
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
}
