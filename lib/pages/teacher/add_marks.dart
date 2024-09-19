import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMarksPage extends StatefulWidget {
  final String studentName;
  final String className;
  final String sectionName;

  const AddMarksPage({
    required this.studentName,
    required this.className,
    required this.sectionName,
    Key? key,
  }) : super(key: key);

  @override
  State<AddMarksPage> createState() => _AddMarksPageState();
}

class _AddMarksPageState extends State<AddMarksPage> {
  String? _selectedExam;
  List<Map<String, dynamic>> _exams = [];
  final TextEditingController _marksController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchExams();
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

  Future<void> _addMarks() async {
    String marksText = _marksController.text.trim();
    int? marks = int.tryParse(marksText);

    if (_selectedExam == null || marks == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please select an exam and enter valid marks",
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
          .doc(widget.studentName)
          .set({
        'studentName': widget.studentName,
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
        title: Text("Add Marks for ${widget.studentName}"),
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
