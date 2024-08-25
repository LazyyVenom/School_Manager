import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier{
  // Instance of Auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //Sign User In
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Sign in
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential;

    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
}
