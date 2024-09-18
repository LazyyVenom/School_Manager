import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClassRegisterPage extends StatefulWidget {
  const ClassRegisterPage({super.key});

  @override
  State<ClassRegisterPage> createState() => _ClassRegisterPageState();
}

class _ClassRegisterPageState extends State<ClassRegisterPage> {
  final TextEditingController _classController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register New Class"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50.0),
            const Text(
              "Register New Class",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _classController,
              decoration: const InputDecoration(
                labelText: "Class Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerClass,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
                    : const Text("Register Class"),
              ),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }

  Future<void> _registerClass() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    String className = _classController.text.trim();

    if (className.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please enter Class Name",
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
      // Update Firestore to add the class and section
      final DocumentReference<Map<String, dynamic>> schoolDoc = FirebaseFirestore.instance.collection('classes').doc('School');
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await schoolDoc.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        final List<String> classes = List<String>.from(data?['classes'] ?? []);

        // Update the list with new class and section if they don't exist
        if (!classes.contains(className)) {
          classes.add(className);
        }
        // Update Firestore document with new class and section
        await schoolDoc.update({
          'classes': classes,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Class Registered Successfully!",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.green[200],
          ),
        );

        // Clear the fields
        _classController.clear();
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
