import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementPage extends StatelessWidget {
  final String role;

  const UserManagementPage({required this.role, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$role Management'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading users.'));
            }

            final users = snapshot.data!.docs.where((doc) => doc['role'] == role.toLowerCase()).toList();

            if (users.isEmpty) {
              return const Center(child: Text('No users found.'));
            }

            return SingleChildScrollView(
              child: Column(
                children: users.map((doc) {
                  final userData = doc.data() as Map<String, dynamic>;
                  return _buildUserCard(context, userData['name'], doc.id, userData['role']);
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, String userName, String userEmail, String userRole) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userEmail,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconButton(context, Icons.lock, Colors.blue[300]!, userEmail, _showChangePasswordDialog),
                _buildIconButton(context, Icons.block, Colors.red[300]!, userEmail, _showDisableAccountDialog),
                _buildIconButton(context, Icons.delete, Colors.orange[300]!, userEmail, _showDeleteAccountDialog),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, Color backgroundColor, String userEmail, Function(BuildContext, String) onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () => onPressed(context, userEmail),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, String userEmail) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Text('Change password for: $userEmail'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDisableAccountDialog(BuildContext context, String userEmail) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Disable Account'),
          content: Text('Disable account for: $userEmail?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, String userEmail) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Text('Delete account for: $userEmail?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
