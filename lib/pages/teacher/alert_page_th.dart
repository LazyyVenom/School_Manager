import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/notification_service.dart';

class AlertPageTh extends StatefulWidget {
  const AlertPageTh({Key? key}) : super(key: key);

  @override
  State<AlertPageTh> createState() => _AlertPageThState();
}

class _AlertPageThState extends State<AlertPageTh> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _notificationController = TextEditingController();

  @override
  void dispose() {
    _notificationController
        .dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context, listen: false);

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
                      currentUser.className!,
                      currentUser.section!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No notifications found'));
                      }

                      final notifications = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          var notification = notifications[index];
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
                                    ),
                                    title: Text(notification['notification'] ??
                                        'No Title'),
                                    subtitle: Text(
                                      "Added At: ${DateFormat('yyyy-MM-dd').format(notification['timestamp'].toDate())}",
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_circle_right,
                                      color: Colors.deepPurple[300],
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Add Notification'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
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
                                _notificationService.sendNotification(
                                  currentUser.className!,
                                  currentUser.section!,
                                  _notificationController.text,
                                );
                                Navigator.of(context).pop();
                                _notificationController
                                    .clear(); 
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please enter notification details'),
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
}
