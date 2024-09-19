import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExamCreatePage extends StatefulWidget {
  const ExamCreatePage({super.key});

  @override
  State<ExamCreatePage> createState() => _ExamCreatePageState();
}

class _ExamCreatePageState extends State<ExamCreatePage> {
  final TextEditingController _highestMarksController = TextEditingController();
  final TextEditingController _examNameController = TextEditingController();
  DateTime? _selectedDate;

  bool _isLoading = false;
  String? _selectedClass;
  String? _selectedSection;
  String? _selectedSubject;
  List<String> _classes = [];
  List<String> _sections = [];
  List<String> _subjects = [];

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

  Future<void> _fetchSubjects() async {
    if (_selectedClass == null || _selectedSection == null) return;

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('subjects')
          .doc('${_selectedClass}_$_selectedSection')
          .get();

      List<String> subjectList = (snapshot.data()?['subjects'] ?? [])
          .map<String>((subject) => subject['name'].toString())
          .toList();

      setState(() {
        _subjects = subjectList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error fetching subjects: $e",
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.red[200],
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Exam"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50.0),
            const Text(
              "Create New Exam",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),

            // Class Dropdown
            DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: const InputDecoration(
                labelText: "Select Class",
                border: OutlineInputBorder(),
              ),
              items: _classes
                  .map((className) => DropdownMenuItem(
                        value: className,
                        child: Text(className),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClass = value;
                  _fetchSubjects(); // Fetch subjects when class is selected
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Section Dropdown
            DropdownButtonFormField<String>(
              value: _selectedSection,
              decoration: const InputDecoration(
                labelText: "Select Section",
                border: OutlineInputBorder(),
              ),
              items: _sections
                  .map((sectionName) => DropdownMenuItem(
                        value: sectionName,
                        child: Text(sectionName),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSection = value;
                  _fetchSubjects(); // Fetch subjects when section is selected
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Subject Dropdown
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: "Select Subject",
                border: OutlineInputBorder(),
              ),
              items: _subjects
                  .map((subjectName) => DropdownMenuItem(
                        value: subjectName,
                        child: Text(subjectName),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Highest Marks Field
            TextField(
              controller: _highestMarksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Highest Marks",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            TextField(
              controller: _examNameController,
              decoration: const InputDecoration(
                labelText: "Highest Marks",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Date Selector
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: _selectedDate == null
                        ? "Select Date"
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createExam,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.deepPurple[200],
                        ),
                      )
                    : const Text("Create Exam"),
              ),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }

  Future<void> _createExam() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    String highestMarksText = _highestMarksController.text.trim();
    String examName = _examNameController.text.trim();
    int? highestMarks = int.tryParse(highestMarksText);

    if (_selectedClass == null ||
        _selectedSection == null ||
        _selectedSubject == null ||
        highestMarks == null ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please fill all the fields correctly",
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
      final DocumentReference<Map<String, dynamic>> examDoc =
          FirebaseFirestore.instance
              .collection('exams')
              .doc('${_selectedClass}_$_selectedSection');

      final DocumentSnapshot<Map<String, dynamic>> snapshot = await examDoc.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        final List<Map<String, dynamic>> exams =
            List<Map<String, dynamic>>.from(data?['exams'] ?? []);

        // Check if exam already exists for the subject
        final existingExam = exams.firstWhere(
            (exam) => exam['subject'] == _selectedSubject,
            orElse: () => {});

        if (existingExam.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Exam for this subject already exists for the selected class and section.",
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.red[200],
            ),
          );
        } else {
          // Add the new exam
          exams.add({
            'examName' : examName,
            'subject': _selectedSubject,
            'highestMarks': highestMarks,
            'date': _selectedDate!.toIso8601String(),
          });

          // Update Firestore with the new exam list
          await examDoc.update({
            'exams': exams,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Exam Created Successfully!",
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.green[200],
            ),
          );

          _highestMarksController.clear();
        }
      } else {
                // Create a new document if it doesn't exist
        await examDoc.set({
          'exams': [
            {
              'subject': _selectedSubject,
              'highestMarks': highestMarks,
              'date': _selectedDate!.toIso8601String(),
            },
          ],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Exam Registered Successfully!",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.green[200],
          ),
        );

        // Clear the fields
        _highestMarksController.clear();
        _selectedDate = null;
        setState(() {
          _selectedSubject = null;
        });
      }
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
}
