import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/notification_service.dart';
import 'package:rxdart/rxdart.dart'; 

class AlertPage extends StatelessWidget {
  const AlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    final NotificationService notificationService = NotificationService();

    // Fetch notifications for both specific class/section and all/all
    final Stream<QuerySnapshot> specificNotificationsStream = notificationService.getNotifications(
      currentUser.className!,
      currentUser.section!,
    );

    final Stream<QuerySnapshot> allNotificationsStream = notificationService.getNotifications(
      'all', // Fetch global notifications
      'all',
    );

    // Combine both streams
    final combinedStream = Rx.combineLatest2<QuerySnapshot, QuerySnapshot, List<DocumentSnapshot>>(
      specificNotificationsStream,
      allNotificationsStream,
      (specificNotifications, allNotifications) {
        // Combine the document lists from both streams
        List<DocumentSnapshot> combinedDocs = [
          ...specificNotifications.docs,
          ...allNotifications.docs,
        ];

        // Sort by timestamp (assuming there is a 'timestamp' field)
        combinedDocs.sort((a, b) {
          Timestamp timestampA = a['timestamp'];
          Timestamp timestampB = b['timestamp'];
          return timestampB.compareTo(timestampA); // Sort in descending order
        });

        return combinedDocs;
      },
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
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
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: combinedStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No notifications found'));
                }

                final notifications = snapshot.data!;

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
                                size: 32,
                              ),
                              title: Text(notification['notification'] ?? 'No Title'),
                              subtitle: Text(
                                "Sent on: ${notification['timestamp'].toDate()}",
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
    );
  }
}
