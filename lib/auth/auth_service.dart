import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomUser {
  final String uid;
  final String email;

  CustomUser({required this.uid, required this.email});
}

class AuthService extends ChangeNotifier{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Method to sign in with email and password
  Future<CustomUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Sign in using Firebase Authentication
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;
      if (user != null) {
        // Return a CustomUser object with uid and email
        return CustomUser(uid: user.uid, email: user.email!);
      }
    } catch (e) {
      // Handle sign-in errors (you can add more specific error handling here)
      return null;
    }
    return null;
  }

  // Method to sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
