import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/chat/chatter.dart';

class ChatsDisplaySt extends StatefulWidget {
  const ChatsDisplaySt({super.key, required this.type});
  final String type;
  
  @override
  State<ChatsDisplaySt> createState() => _ChatsDisplayStState();
}

class _ChatsDisplayStState extends State<ChatsDisplaySt> {
  String? _selectedClass;  // Variable for storing selected class
  String? _selectedSection;  // Variable for storing selected section

  List<String> _classes = [];  // List to hold classes from Firestore
  List<String> _sections = [];  // List to hold sections from Firestore

  // Method to fetch classes and sections from Firestore
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

  // Call fetch method when widget is initialized
  @override
  void initState() {
    super.initState();
    _fetchClassesAndSections();
  }

  // Method to build the user list from Firestore
  Widget _buildUserList(CurrentUser currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading users.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter the data based on class and section
        final filteredUsers = snapshot.data!.docs.where((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          return (data['class'] == _selectedClass || _selectedClass == null) &&
                 (data['section'] == _selectedSection || _selectedSection == null) &&
                 (currentUser.gmail != data['email']) &&
                 widget.type.toLowerCase().contains(data['role']);
        }).toList();

        return ListView(
          children: filteredUsers.map((DocumentSnapshot document) {
            return Padding(
              padding: const EdgeInsets.only(top: 3),
              child: _buildUserListItem(document, currentUser),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
      DocumentSnapshot document, CurrentUser currentUser) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        tileColor: Colors.deepPurple[50],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple[100],
          child: Icon(
            Icons.person,
            color: Colors.deepPurple[400],
          ),
        ),
        title: Text(
          data['name'] ?? 'Unknown User',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          data['email'] ?? 'Role: Unknown',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.deepPurple[400],
          size: 20,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                type: data['name'],
                email: data['email'],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Contact ${widget.type}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Dropdown for selecting class
                DropdownButton<String>(
                  value: _selectedClass,
                  hint: const Text('Select Class'),
                  items: _classes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedClass = newValue;
                    });
                  },
                ),

                // Dropdown for selecting section
                DropdownButton<String>(
                  value: _selectedSection,
                  hint: const Text('Select Section'),
                  items: _sections.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSection = newValue;
                    });
                  },
                ),
              ],
            ),
          ),

          // Display filtered user list
          Expanded(child: _buildUserList(currentUser)),
        ],
      ),
    );
  }
}
