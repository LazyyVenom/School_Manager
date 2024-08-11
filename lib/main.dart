import 'package:flutter/material.dart';
import 'package:school_manager/basic_structure.dart';

void main() {
  runApp(const SchoolManagerApp());
}

// need to start working soon

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
    return const BasicStructure();
  }
}