import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/student_dashboard.dart';
import 'package:school_manager/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User is Logged In
          if (snapshot.hasData) {
            return const StudentDashboard();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
