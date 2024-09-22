import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/notification_service.dart';
import 'package:async/async.dart'; // Import the async package for StreamGroup

class AlertPageMt extends StatefulWidget {
  const AlertPageMt({Key? key}) : super(key: key);

  @override
  State<AlertPageMt> createState() => _AlertPageMtState();
}

class _AlertPageMtState extends State<AlertPageMt> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _notificationController = TextEditingController();
  final _streamGroup = StreamGroup<QuerySnapshot>(); // Create a stream group

  @override
  void initState() {
    super.initState();
    // Add both streams to the group
    _streamGroup.add(_notificationService.getNotifications('manage', 'ment'));
    _streamGroup.add(_notificationService.getNotifications('all', 'all'));
  }

  @override
  void dispose() {
    _notificationController.dispose();
    _streamGroup.close(); // Close the stream group
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              "All Activities",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _streamGroup.stream, // Listen to the combined stream
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
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.notifications,
                              color: Colors.deepPurple[300],
                              size: 32,
                            ),
                            title: Text(
                              notification['notification'] ?? 'No Title',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Added At: ${DateFormat('yyyy-MM-dd').format(notification['timestamp'].toDate())}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red[400]),
                              onPressed: () => _showDeleteConfirmation(context, docId),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNotificationDialog(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _notificationController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Notification Details',
                ),
              ),
            ],
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
                  _notificationService.sendNotification('management', 'ment', _notificationController.text);
                  Navigator.of(context).pop();
                  _notificationController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter notification details')),
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
