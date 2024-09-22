import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubjectRegisterPage extends StatefulWidget {
  const SubjectRegisterPage({super.key});

  @override
  State<SubjectRegisterPage> createState() => _SubjectRegisterPageState();
}

class _SubjectRegisterPageState extends State<SubjectRegisterPage> {
  final TextEditingController _subjectController = TextEditingController();

  bool _isLoading = false;
  String? _selectedClass;
  String? _selectedSection;
  List<String> _classes = [];
  List<String> _sections = [];

  @override
  void initState() {
    super.initState();
    _fetchClassesAndSections();
  }

  Future<void> _fetchClassesAndSections() async {
    try {
      // Fetching the classes and sections from Firestore at 'classes -> School'
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register New Subject for Class"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50.0),
            const Text(
              "Register New Subject",
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
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Subject Name Field
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: "Subject Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerSubject,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
                    : const Text("Register Subject"),
              ),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }

  Future<void> _registerSubject() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    String subjectName = _subjectController.text.trim();

    if (_selectedClass == null ||
        _selectedSection == null ||
        subjectName.isEmpty) {
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
      // Document reference based on the selected class and section
      final DocumentReference<Map<String, dynamic>> classSectionDoc =
          FirebaseFirestore.instance
              .collection('subjects')
              .doc('${_selectedClass}_$_selectedSection');

      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await classSectionDoc.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        final List<Map<String, dynamic>> subjects =
            List<Map<String, dynamic>>.from(data?['subjects'] ?? []);

        // Check if subject already exists
        final existingSubject = subjects.firstWhere(
            (subject) => subject['name'] == subjectName,
            orElse: () => {});

        if (existingSubject.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Subject already registered for this class and section.",
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.red[200],
            ),
          );
        } else {
          // Add the new subject with marks
          subjects.add({
            'name': subjectName,
          });

          // Update Firestore with the new subject list
          await classSectionDoc.update({
            'subjects': subjects,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Subject Registered Successfully!",
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.green[200],
            ),
          );

          _subjectController.clear();
        }
      } else {
        // Create a new document if it doesn't exist
        await classSectionDoc.set({
          'subjects': [
            {
              'name': subjectName,
            },
          ],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Class, Section, and Subject Registered Successfully!",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.green[200],
          ),
        );

        // Clear the fields
        _subjectController.clear();
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