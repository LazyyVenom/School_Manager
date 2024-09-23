// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore package
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/auth/auth_service.dart';
import 'package:school_manager/dashboards/nurse_dashboard.dart';
import 'package:school_manager/dashboards/student_dashboard.dart';
import 'package:school_manager/dashboards/teacher_dashboard.dart';
import 'package:school_manager/dashboards/management_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50.0),
            const Text(
              "Welcome Back!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _usernameController,
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
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
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
                          backgroundColor: Colors.deepPurple[100],
                          color: Colors.deepPurple,
                        ),
                      )
                    : const Text("Login"),
              ),
            ),
            const SizedBox(height: 5.0),
            TextButton(
              onPressed: _isLoading ? null : _forgotPassword,
              child: const Text("Forgot Password?"),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }

  void _login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = Provider.of<CurrentUser>(context, listen: false);

    String email = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    print("Email: $email Password: $password");

    try {
      final user =
          await authService.signInWithEmailAndPassword(email, password);

      if (user == null) {
        throw ("ID Password Didn't Matched");
      }


      // Fetch user role from Firestore using email as UID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get();

      if (userDoc.exists) {
        final role = userDoc.data()?['role'];

        if (context.mounted) {
          String? className;
          String? section;

          if (role != 'management' || role != 'nurse') {
            className = userDoc['class'] ?? '';
            section = userDoc['section'] ?? '';
          }

          currentUser.updateUser(
            newGmail: user.email,
            newName: userDoc['name'] ?? '',
            newAccountType: role,
            newClassName: className ?? '',
            newSection: section ?? '',
            newPassword: password,
          );

          if (role == 'student') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StudentDashboard()),
            );
          } else if (role == 'teacher') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TeacherDashboard()),
            );
          } else if (role == 'management') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const ManagementDashboard()),
            );
          } else if (role == 'nurse') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const NurseDashboard()),
            );
          } else {
            throw Exception("Unknown role: $role");
          }
        }
      } else {
        throw Exception("User data not found");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.yellow[200],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Please contact your Teacher/Management!",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.red[200],
      ),
    );
  }
}

