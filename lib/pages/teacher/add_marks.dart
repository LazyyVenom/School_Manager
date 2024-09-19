import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMarksPage extends StatefulWidget {
  final String className;
  final String sectionName;

  const AddMarksPage({
    required this.className,
    required this.sectionName,
    Key? key,
  }) : super(key: key);

  @override
  State<AddMarksPage> createState() => _AddMarksPageState();
}

class _AddMarksPageState extends State<AddMarksPage> {
  String? _selectedExam;
  String? _selectedStudent;
  List<Map<String, dynamic>> _exams = [];
  List<Map<String, dynamic>> _students = [];
  final TextEditingController _marksController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchExams();
    _fetchStudents(); // Fetch students from the 'users' collection
  }

  Future<void> _fetchExams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch exams for the selected class and section
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('exams')
          .doc('${widget.className}_${widget.sectionName}')
          .get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> examList =
            List<Map<String, dynamic>>.from(snapshot.data()?['exams'] ?? []);
        setState(() {
          _exams = examList;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error fetching exams: $e",
            style: const TextStyle(color: Colors.black),
          ),
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
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch students from 'users' collection where role == 'student'
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'student')
              .where('class', isEqualTo: widget.className) // Class filter
              .where('section', isEqualTo: widget.sectionName) // Section filter
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
          content: Text(
            "Error fetching students: $e",
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.red[200],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addMarks() async {
    String marksText = _marksController.text.trim();
    int? marks = int.tryParse(marksText);

    if (_selectedStudent == null || _selectedExam == null || marks == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please select a student, exam, and enter valid marks",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.red[200],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Adding marks to the 'marks' collection
      await FirebaseFirestore.instance
          .collection('marks')
          .doc(_selectedStudent) // Document ID as student ID
          .set({
        'studentName': _selectedStudent,
        'class': widget.className,
        'section': widget.sectionName,
        'exam': _selectedExam,
        'marks': marks,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Marks added successfully!",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.green[200],
        ),
      );

      _marksController.clear();
      setState(() {
        _selectedExam = null;
        _selectedStudent = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
            style: const TextStyle(color: Colors.black),
          ),
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
        title: const Text("Add Marks"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Student Dropdown
            DropdownButtonFormField<String>(
              value: _selectedStudent,
              decoration: const InputDecoration(
                labelText: "Select Student",
                border: OutlineInputBorder(),
              ),
              items: _students.map((student) {
                return DropdownMenuItem<String>(
                  value: student['studentName'],
                  child: Text(student['studentName']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStudent = value;
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Exam Dropdown
            DropdownButtonFormField<String>(
              value: _selectedExam,
              decoration: const InputDecoration(
                labelText: "Select Exam",
                border: OutlineInputBorder(),
              ),
              items: _exams.map((exam) {
                return DropdownMenuItem<String>(
                  value:
                      exam['examName'], // Assuming each exam has an 'examName'
                  child: Text(exam['examName']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExam = value;
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Marks Input Field
            TextField(
              controller: _marksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Marks",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addMarks,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  textStyle: const TextStyle(fontSize: 18.0),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Add Marks"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
