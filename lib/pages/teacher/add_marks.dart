import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMarksPage extends StatefulWidget {
  final String studentEmail;
  final String className;
  final String sectionName;

  const AddMarksPage({
    Key? key,
    required this.studentEmail,
    required this.className,
    required this.sectionName,
  }) : super(key: key);

  @override
  State<AddMarksPage> createState() => _AddMarksPageState();
}

class _AddMarksPageState extends State<AddMarksPage> {
  String? _selectedExam;
  String? _selectedSubject;
  List<String> _exams = [];
  List<String> _subjects = [];
  final TextEditingController _marksController = TextEditingController();
  bool _isLoadingExams = false;
  bool _isLoadingSubjects = false;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  /// Fetch exams from Firestore based on class and section
  Future<void> _fetchExams() async {
    setState(() {
      _isLoadingExams = true;
    });

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('exams')
          .doc('${widget.className}_${widget.sectionName}')
          .get();

      if (snapshot.exists) {
        List<String> examList = snapshot.data()!.keys.toList();

        setState(() {
          _exams = examList; // Show all exam names
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching exams: $e"),
          backgroundColor: Colors.red[200],
        ),
      );
    } finally {
      setState(() {
        _isLoadingExams = false;
      });
    }
  }

  /// Fetch subjects for the selected exam
  Future<void> _fetchSubjects() async {
    if (_selectedExam == null) return;

    setState(() {
      _isLoadingSubjects = true;
    });

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('exams')
          .doc('${widget.className}_${widget.sectionName}')
          .get();

      if (snapshot.exists) {
        var selectedExamData = snapshot.data()?[_selectedExam];

        if (selectedExamData != null && selectedExamData is List) {
          List<String> subjects = [];
          for (var subjectData in selectedExamData) {
            if (subjectData is Map<String, dynamic> &&
                subjectData.containsKey('subject')) {
              subjects.add(subjectData['subject']);
            }
          }

          setState(() {
            _subjects = subjects;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching subjects: $e"),
          backgroundColor: Colors.red[200],
        ),
      );
    } finally {
      setState(() {
        _isLoadingSubjects = false;
      });
    }
  }

  /// Add marks to the 'studentMarks' collection
  Future<void> _addMarks() async {
    String marksText = _marksController.text.trim();
    int? marks = int.tryParse(marksText);

    if (_selectedExam == null || _selectedSubject == null || marks == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              "Please select an exam, a subject, and enter valid marks"),
          backgroundColor: Colors.red[200],
        ),
      );
      return;
    }

    try {
      DocumentReference<Map<String, dynamic>> studentDoc = FirebaseFirestore
          .instance
          .collection('studentMarks')
          .doc(widget.studentEmail);

      // Prepare the data structure
      final examData = {
        'subject': _selectedSubject,
        'marks': marks,
      };

      // Add or update the marks for the selected exam and subject
      await studentDoc.set({
        _selectedExam!: FieldValue.arrayUnion([examData]),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Marks added successfully!"),
          backgroundColor: Colors.green[400],
        ),
      );

      _marksController.clear();
      setState(() {
        _selectedExam = null;
        _selectedSubject = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding marks: $e"),
          backgroundColor: Colors.red[200],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Marks for ${widget.studentEmail}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedExam,
              decoration: const InputDecoration(
                labelText: "Select Exam",
                border: OutlineInputBorder(),
              ),
              items: _exams.map((exam) {
                return DropdownMenuItem(
                  value: exam,
                  child: Text(exam),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExam = value;
                  _fetchSubjects(); // Fetch subjects when an exam is selected
                });
              },
            ),
            const SizedBox(height: 16),
            if (_subjects.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: "Select Subject",
                  border: OutlineInputBorder(),
                ),
                items: _subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _marksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Marks",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addMarks,
              child: const Text("Add Marks"),
            ),
            const SizedBox(height: 16),
            if (_isLoadingExams || _isLoadingSubjects)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
