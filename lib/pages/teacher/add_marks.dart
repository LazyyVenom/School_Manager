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
  List<String> _exams = [];
  final TextEditingController _marksController = TextEditingController();
  bool _isLoadingExams = false;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

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
        List<dynamic> examList = snapshot.data()?['exams'] ?? [];
        setState(() {
          _exams = examList.map<String>((exam) {
            return '${exam['examName']} - ${exam['subject']}';
          }).toList();
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

  Future<void> _addMarks() async {
    String marksText = _marksController.text.trim();
    int? marks = int.tryParse(marksText);

    if (_selectedExam == null || marks == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select an exam and enter marks"),
          backgroundColor: Colors.red[200],
        ),
      );
      return;
    }

    try {
      // Add marks to Firestore
      final examName = _selectedExam!.split(' - ')[0]; // Get the exam name from the selected exam
      final subjectName = _selectedExam!.split(' - ')[1]; // Get the subject name

      DocumentReference<Map<String, dynamic>> marksDoc = FirebaseFirestore
          .instance
          .collection('studentMarks')
          .doc(widget.studentEmail);

      await marksDoc.set({
        examName: {
          'subject': subjectName,
          'marks': marks,
        },
      }, SetOptions(merge: true)); // Use merge to avoid overwriting existing data

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Marks added successfully!"),
          backgroundColor: Colors.green[400],
        ),
      );

      _marksController.clear();
      setState(() {
        _selectedExam = null; // Reset exam selection
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
            if (_isLoadingExams) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
