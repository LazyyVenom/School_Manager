import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore package
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/auth/auth_service.dart';

class ManagementRegisterPage extends StatefulWidget {
  const ManagementRegisterPage({super.key});

  @override
  State<ManagementRegisterPage> createState() => _ManagementRegisterPageState();
}

class _ManagementRegisterPageState extends State<ManagementRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Management"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50.0),
            const Text(
              "Register New Management",
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerManagement,
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

  void _registerManagement() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();

    try {
      // Register the management user using Firebase Authentication
      await authService.registerWithEmailAndPassword(email, password);

      // Store management details in Firestore using email as UID
      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'email': email,
        'name': name,
        'role': 'management',
        'password': password,
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Management Registered Successfully!",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.green[200],
        ),
      );

      // Clear the fields
      _emailController.clear();
      _nameController.clear();
      _passwordController.clear();
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
