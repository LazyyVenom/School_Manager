import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore package
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/auth/auth_service.dart';

class StudentRegisterPage extends StatefulWidget {
  const StudentRegisterPage({super.key});

  @override
  State<StudentRegisterPage> createState() => _StudentRegisterPageState();
}
class _StudentRegisterPageState extends State<StudentRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNumberController =
      TextEditingController(); // Roll Number Controller

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
      // Fetch classes and sections from Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('classes')
          .doc('School')
          .get();

      if (snapshot.exists) {
        setState(() {
          _classes = List<String>.from(snapshot.data()?['classes'] ?? []);
          _sections = List<String>.from(snapshot.data()?['sections'] ?? []);
        });
      }
    } catch (e) {
      // Handle errors if any
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error fetching class/section data: $e",
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
        title: const Text("Register Student"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50.0),
            const Text(
              "Register New Student",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Roll Number Field
            TextField(
              controller: _rollNumberController,
              decoration: const InputDecoration(
                labelText: "Roll Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Dropdown for Class
            DropdownButtonFormField<String>(
              value: _selectedClass,
              hint: const Text('Select Class'),
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
              decoration: const InputDecoration(
                labelText: "Class",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Dropdown for Section
            DropdownButtonFormField<String>(
              value: _selectedSection,
              hint: const Text('Select Section'),
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
              decoration: const InputDecoration(
                labelText: "Section",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerStudent,
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
                    : const Text("Register"),
              ),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }

  void _registerStudent() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String rollNumber = _rollNumberController.text.trim();
    String? classAssigned = _selectedClass;
    String? section = _selectedSection;

    if (classAssigned == null || section == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please select both Class and Section.",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.red[200],
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Register the student using Firebase Authentication
      await authService.registerWithEmailAndPassword(email, password);

      // Store additional student details in Firestore using email as UID
      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'email': email,
        'name': name,
        'password': password,
        'role': 'student',
        'class': classAssigned,
        'section': section,
        'rollNumber': rollNumber,
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Student Registered Successfully!",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.green[200],
        ),
      );

      // Clear the fields
      _emailController.clear();
      _nameController.clear();
      _passwordController.clear();
      _rollNumberController.clear(); // Clear roll number field
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
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
