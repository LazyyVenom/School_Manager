import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';

class UserManagementPage extends StatefulWidget {
  final String role;

  const UserManagementPage({required this.role, Key? key}) : super(key: key);

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<String> _classes = []; // List to hold classes from Firestore
  List<String> _sections = []; // List to hold sections from Firestore

  String? selectedClass;
  String? selectedSection;

  @override
  void initState() {
    super.initState();
    _fetchClassesAndSections();
  }

  Future<void> _fetchClassesAndSections() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc('School')
          .get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _classes = List<String>.from(data['classes']);
        _sections = List<String>.from(data['sections']);
      });
    } catch (error) {
      print('Error fetching classes and sections: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role} Management'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.role.toLowerCase() == 'student' ||
                widget.role.toLowerCase() == 'teacher')
              _buildDropdowns(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading users.'));
                  }

                  // Filter users based on selected class and section
                  final users = snapshot.data!.docs.where((doc) {
                    final userData = doc.data() as Map<String, dynamic>;
                    bool matchesRole =
                        userData['role'] == widget.role.toLowerCase();
                    bool matchesClass = selectedClass == null ||
                        userData['class'] == selectedClass;
                    bool matchesSection = selectedSection == null ||
                        userData['section'] == selectedSection;
                    return matchesRole && matchesClass && matchesSection;
                  }).toList();

                  if (users.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: users.map((doc) {
                        final userData = doc.data() as Map<String, dynamic>;
                        return _buildUserCard(context, userData['name'], doc.id,
                            userData['role']);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              color: Colors.white,
            ),
            child: DropdownButton<String>(
              hint: const Text('Select Class'),
              isExpanded: true,
              value: selectedClass,
              onChanged: (newValue) {
                setState(() {
                  selectedClass = newValue;
                  selectedSection = null; // Reset section on class change
                });
              },
              items: _classes.map((classItem) {
                return DropdownMenuItem<String>(
                  value: classItem,
                  child: Text(classItem),
                );
              }).toList(),
              underline: Container(), // Remove underline
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              color: Colors.white,
            ),
            child: DropdownButton<String>(
              hint: const Text('Select Section'),
              isExpanded: true,
              value: selectedSection,
              onChanged: (newValue) {
                setState(() {
                  selectedSection = newValue;
                });
              },
              items: _sections.map((sectionItem) {
                return DropdownMenuItem<String>(
                  value: sectionItem,
                  child: Text(sectionItem),
                );
              }).toList(),
              underline: Container(), // Remove underline
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, String userName, String userEmail,
      String userRole) {
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
                _buildIconButton(context, Icons.lock, Colors.blue[300]!,
                    userEmail, _showChangePasswordDialog),
                _buildIconButton(context, Icons.block, Colors.red[300]!,
                    userEmail, _showDisableAccountDialog),
                _buildIconButton(context, Icons.delete, Colors.orange[300]!,
                    userEmail, _showDeleteAccountDialog),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
      BuildContext context,
      IconData icon,
      Color backgroundColor,
      String userEmail,
      Function(BuildContext, String) onPressed) {
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

  void _showDisableAccountDialog(BuildContext context, String userEmail) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Disable Account'),
          content: Text('Disable account for: $userEmail?'),
          actions: [
            TextButton(
              onPressed: () {
                _disableAccount(userEmail);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, String userEmail) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Text('Delete account for: $userEmail?'),
          actions: [
            TextButton(
              onPressed: () {
                _deleteAccount(userEmail, currentUser);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, String userEmail) {
    TextEditingController passwordController = TextEditingController();
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(hintText: "Enter new password"),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String newPassword = passwordController.text.trim();
                if (newPassword.isNotEmpty) {
                  await _changePassword(userEmail, newPassword);
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: currentUser.gmail!,
                      password: currentUser.password!);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a password.')),
                  );
                }
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

// Change Password Method
  Future<void> _changePassword(String userEmail, String newPassword) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .get();

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      String oldPassword = data['password'] as String;
      // Now you can use oldPassword as needed

      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: oldPassword);

      User? user = FirebaseAuth.instance.currentUser;
      await user!.updatePassword(newPassword);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .update({
        'password': newPassword,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to change password.')),
      );
      print('Error changing password: $error');
    }
  }

// Disable Account Method
  Future<void> _disableAccount(String userEmail) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .update({
        'isActive': false, // Update the user's status
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account disabled successfully!')),
      );
    } catch (error) {
      print('Error disabling account: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to disable account.')),
      );
    }
  }

// Delete Account Method
  Future<void> _deleteAccount(String userEmail, CurrentUser currentUser) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .get();

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      String oldPassword = data['password'] as String;
      // Now you can use oldPassword as needed

      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: oldPassword);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .delete();

      User? user = FirebaseAuth.instance.currentUser;
      await user!.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully!')),
      );
    } catch (error) {
      print('Error deleting account: $error');
    } finally {
      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: currentUser.gmail!, password: currentUser.password!);
    }
  }
}
