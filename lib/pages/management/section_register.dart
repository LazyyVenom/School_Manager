import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SectionRegisterPage extends StatefulWidget {
  const SectionRegisterPage({super.key});

  @override
  State<SectionRegisterPage> createState() => _SectionRegisterPageState();
}

class _SectionRegisterPageState extends State<SectionRegisterPage> {
  final TextEditingController _SectionController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register New Section"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50.0),
            const Text(
              "Register New Section",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _SectionController,
              decoration: const InputDecoration(
                labelText: "Section Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerSection,
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
                    : const Text("Register Section"),
              ),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }

  Future<void> _registerSection() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    String sectionName = _SectionController.text.trim();

    if (sectionName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please enter Section Name",
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
      // Update Firestore to add the Section and section
      final DocumentReference<Map<String, dynamic>> schoolDoc = FirebaseFirestore.instance.collection('classes').doc('School');
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await schoolDoc.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        final List<String> sections = List<String>.from(data?['sections'] ?? []);

        // Update the list with new Section and section if they don't exist
        if (!sections.contains(sectionName)) {
          sections.add(sectionName);
        }
        // Update Firestore document with new Section and section
        await schoolDoc.update({
          'sections': sections,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Section Registered Successfully!",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.green[200],
          ),
        );

        // Clear the fields
        _SectionController.clear();
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
