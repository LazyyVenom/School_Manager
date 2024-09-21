import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/notification_service.dart';

class AlertPageMt extends StatefulWidget {
  const AlertPageMt({Key? key}) : super(key: key);

  @override
  State<AlertPageMt> createState() => _AlertPageMtState();
}

class _AlertPageMtState extends State<AlertPageMt> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _notificationController = TextEditingController();

  String? _selectedRole = 'management';
  String? _selectedClass;
  String? _selectedSection;

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 6),
                Text(
                  "All Activities",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Divider(),
                const SizedBox(height: 6),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _notificationService.getNotifications(
                      _selectedRole == 'management'
                          ? 'all'
                          : (_selectedClass ?? 'all'),
                      _selectedRole == 'management'
                          ? 'all'
                          : (_selectedSection ?? 'all'),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No notifications found'));
                      }

                      final notifications = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          var notification = notifications[index];
                          var docId = notification.id;

                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(1),
                                  color: Colors.deepPurple[50],
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.notifications,
                                      color: Colors.deepPurple[300],
                                      size: 32,
                                    ),
                                    title: Text(notification['notification'] ?? 'No Title'),
                                    subtitle: Text(
                                      "Added At: ${DateFormat('yyyy-MM-dd').format(notification['timestamp'].toDate())}",
                                    ),
                                    trailing: GestureDetector(
                                      onTap: () {
                                        _showDeleteConfirmation(context, docId);
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red[300],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  _showAddNotificationDialog(context);
                },
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNotificationDialog(BuildContext context) {
    // Local variables to handle state inside the dialog only
    String? selectedRole = 'management';
    String? selectedClass;
    String? selectedSection;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Notification'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'management',
                        child: Text('management'),
                      ),
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All'),
                      ),
                      DropdownMenuItem(
                        value: 'Specific Classes',
                        child: Text('Specific Classes'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                        selectedClass = null;
                        selectedSection = null;
                      });
                    },
                  ),
                  if (selectedRole == 'Specific Classes') ...[
                    FutureBuilder<List<String>>(
                      future: _fetchClasses(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final classes = snapshot.data!;
                        return DropdownButton<String>(
                          value: selectedClass,
                          hint: const Text('Select Class'),
                          items: classes
                              .map((className) => DropdownMenuItem(
                                    value: className,
                                    child: Text(className),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedClass = value;
                              selectedSection = null;
                            });
                          },
                        );
                      },
                    ),
                    if (selectedClass != null)
                      FutureBuilder<List<String>>(
                        future: _fetchSections(selectedClass!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final sections = snapshot.data!;
                          return DropdownButton<String>(
                            value: selectedSection,
                            hint: const Text('Select Section'),
                            items: sections
                                .map((sectionName) => DropdownMenuItem(
                                      value: sectionName,
                                      child: Text(sectionName),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSection = value;
                              });
                            },
                          );
                        },
                      ),
                  ],
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notificationController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Notification Details',
                    ),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                if (_notificationController.text.isNotEmpty) {
                  _notificationService.sendNotification(
                    selectedRole == 'management'
                        ? 'management'
                        : selectedRole == 'All'
                            ? 'all'
                            : (selectedClass ?? 'all'),
                    selectedRole == 'management' || selectedRole == 'All'
                        ? 'all'
                        : (selectedSection ?? 'all'),
                    _notificationController.text,
                  );
                  Navigator.of(context).pop();
                  _notificationController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter notification details'),
                    ),
                  );
                }
              },
              child: const Text('Enter'),
            ),
          ],
        );
      },
    );
  }

  // Fetch list of classes from 'School' document
  Future<List<String>> _fetchClasses() async {
    final snapshot = await FirebaseFirestore.instance.collection('classes').doc('School').get();
    List<String> classes = List<String>.from(snapshot.data()?['classes'] ?? []);
    return classes;
  }

  // Fetch list of sections from 'School' document based on the selected class
  Future<List<String>> _fetchSections(String selectedClass) async {
    final snapshot = await FirebaseFirestore.instance.collection('classes').doc('School').get();
    List<String> sections = List<String>.from(snapshot.data()?['sections'] ?? []);
    return sections;
  }

  void _showDeleteConfirmation(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content: const Text('Are you sure you want to delete this notification?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _notificationService.deleteNotification(docId, 'allall');
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
