import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_manager/basic_structure.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _userRole = 'Teacher'; // Default role selected

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
                labelText: "Username",
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
            const SizedBox(height: 24.0),

            // Radio Buttons for Role Selection
            const Text(
              "Select Role:",
              style: TextStyle(fontSize: 18.0),
            ),
            RadioListTile<String>(
              title: const Text('Teacher'),
              value: 'Teacher',
              groupValue: _userRole,
              onChanged: (String? value) {
                setState(() {
                  _userRole = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Management'),
              value: 'Management',
              groupValue: _userRole,
              onChanged: (String? value) {
                setState(() {
                  _userRole = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Student'),
              value: 'Student',
              groupValue: _userRole,
              onChanged: (String? value) {
                setState(() {
                  _userRole = value!;
                });
              },
            ),

            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text("Login"),
            ),
            const SizedBox(height: 5.0),
            TextButton(
              onPressed: _forgotPassword,
              child: const Text("Forgot Password?"),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Add logic to handle different roles if needed
    if (username.trim() == 'a' && password.trim() == 'a') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true); // Save login state
      await prefs.setString('userRole', _userRole); // Optionally save the role

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BasicStructure()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Incorrect ID or Password!",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.yellow[200],
        ),
      );
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Please Contact Your Teacher!",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.red[200],
      ),
    );
  }
}
