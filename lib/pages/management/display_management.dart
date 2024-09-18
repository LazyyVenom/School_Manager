import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayManagementAccounts extends StatefulWidget {
  const DisplayManagementAccounts({super.key});

  @override
  State<DisplayManagementAccounts> createState() => _DisplayManagementAccountsState();
}

class _DisplayManagementAccountsState extends State<DisplayManagementAccounts> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .where('role', whereIn: ['management','nurse'])
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management & Nurse Accounts'),
        backgroundColor: Theme.of(context).primaryColor, // Deep Purple from theme
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'An error occurred while fetching accounts.',
                style: TextStyle(color: Colors.red), // Error message with red color
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return const Center(
              child: Text(
                'No management or nurse accounts found.',
                style: TextStyle(color: Colors.grey), // Informative text with grey color
              ),
            );
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
              final String name = data['name'];
              final String email = data['email'];
              final String role = data['role'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: getRoleColor(role),
                  child: Icon(
                    getRoleIcon(role),
                    color: Colors.white, // White icon for better contrast
                  ),
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1!.color, // Deep Purple text
                  ),
                ),
                subtitle: Text(
                  email,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.caption!.color, // Lighter shade for email
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData getRoleIcon(String role) {
    switch (role) {
      case 'management':
        return Icons.person_pin;
      case 'nurse':
        return Icons.local_hospital;
      default:
        return Icons.person;
    }
  }

  Color getRoleColor(String role) {
    switch (role) {
      case 'management':
        return Colors.deepPurple; // Use exact Deep Purple
      case 'nurse':
        return Colors.lightGreen; // Adjust as needed
      default:
        return Colors.grey;
    }
  }
}