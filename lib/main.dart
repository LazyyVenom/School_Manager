import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/auth/auth_gate.dart';
import 'package:school_manager/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SchoolManagerApp());
}

class SchoolManagerApp extends StatelessWidget {
  const SchoolManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Manager',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple
      ),
      home: const SchoolManager(),
    );
  }
}

class SchoolManager extends StatefulWidget {
  const SchoolManager({super.key});

  @override
  State<SchoolManager> createState() => _SchoolManagerState();
}

class _SchoolManagerState extends State<SchoolManager> {
  @override
  Widget build(BuildContext context) {
    return const AuthGate();
  }
}