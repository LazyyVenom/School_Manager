import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/dashboards/student_dashboard.dart';
import 'package:school_manager/dashboards/teacher_dashboard.dart';
import 'package:school_manager/dashboards/management_dashboard.dart';
import 'package:school_manager/pages/login_page.dart';
import 'package:school_manager/additional_features.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User is not logged in
          if (!snapshot.hasData) {
            return const LoginPage();
          }

          // User is logged in, check the role
          User? user = snapshot.data;

          if (user != null) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.email) // Use email as the document ID
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return const Center(
                    child: Text("Error loading user data."),
                  );
                }

                var userData = snapshot.data!;
                String role = userData['role'];
                String? className;
                String? section;

                if (role != 'management') {
                  className = userData['class'];
                  section = userData['section'];
                } 

                CurrentUser currentUser =
                    Provider.of<CurrentUser>(context, listen: false);
                currentUser.updateUser(
                  newGmail: user.email!,
                  newName: userData['name'] ?? '',
                  newAccountType: role,
                  newClassName: className ?? '',
                  newSection: section ?? '',
                );

                // Navigate to the appropriate dashboard
                if (role == 'management') {
                  return const ManagementDashboard();
                } else if (role == 'teacher') {
                  return const TeacherDashboard();
                } else if (role == 'student') {
                  return const StudentDashboard();
                } else {
                  return const Center(
                    child: Text("Unknown role."),
                  );
                }
              },
            );
          }

          return const LoginPage();
        },
      ),
    );
  }
}
