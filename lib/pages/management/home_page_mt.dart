import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/chat/chat_displayer_st.dart';
import 'package:school_manager/chat/chat_displayer_unread.dart';
import 'package:school_manager/pages/management/admin_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_manager/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('isLoggedIn');

  if (context.mounted) {
    _navigateToLoginPage(context);
  }
}

void _navigateToLoginPage(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
    (Route<dynamic> route) => false, // This removes all the previous routes
  );
}

class HomePageMt extends StatelessWidget {
  const HomePageMt({super.key});

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    return Scaffold(
      body: SingleChildScrollView(
        // Make the body scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card (already exists)
              SizedBox(
                height: 75,
                width: double.infinity,
                child: Card(
                  color: Colors.deepPurple[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Flexible(
                          child: Text(
                            "Welcome ${currentUser.name}",
                            style:
                                Theme.of(context).textTheme.headline5?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Text(
                          "Administrator",
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.deepPurple[50]),
                      ),
                      onPressed: () {
                        // Add functionality for changing password
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text("Change Password"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.red[50]),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.red[400]),
                        overlayColor:
                            MaterialStateProperty.all(Colors.red[100]),
                      ),
                      onPressed: () {
                        logout(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text("Log Out"),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notification box for new messages
              InkWell(
                onTap: () {
                  // Navigate to the list of users who sent messages
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationListScreen(),
                    ),
                  );
                },
                child: Card(
                  color: Colors.orange[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "New Messages",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            StreamBuilder<int>(
                              stream:
                                  getNewMessageCountStream(currentUser.gmail!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.grey,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  );
                                }

                                if (snapshot.hasData) {
                                  final count = snapshot.data!;
                                  return CircleAvatar(
                                    radius: 18,
                                    backgroundColor: count > 0
                                        ? Colors.red[400]
                                        : Colors.grey,
                                    child: Text(
                                      count > 0 ? '$count' : '0',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                } else {
                                  return const CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.grey,
                                    child: Text(
                                      '0',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                "Perform Tasks",
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 16),

              // Existing functionality buttons
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ChatsDisplaySt(type: "Teachers")),
                            );
                          },
                          child: Card(
                            color: Colors.deepPurple[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text("Contact Teachers"),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Icon(
                                    Icons.person,
                                    size: 55,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ChatsDisplaySt(type: 'Students')),
                            );
                          },
                          child: Card(
                            color: Colors.deepPurple[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text("Contact Students"),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Icon(
                                    Icons.boy,
                                    size: 55,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AdminPanel()),
                            );
                          },
                          child: Card(
                            color: Colors.deepPurple[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text("Admin Panel"),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.assignment_ind,
                                    size: 70,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<int> getNewMessageCountStream(String userEmail) async* {
    Set<String> uniqueSenders = {};

    // Listen for changes in the chat_rooms collection
    await for (var snapshot
        in FirebaseFirestore.instance.collection('chat_rooms').snapshots()) {
      uniqueSenders.clear(); // Clear the previous senders

      for (var doc in snapshot.docs) {
        String chatRoomId = doc.id;

        if (chatRoomId.contains(userEmail)) {
          // Access the messages array in this chat room document
          var messages = doc['messages'] as List<dynamic>?;

          if (messages != null && messages.isNotEmpty) {
            var lastMessage = messages.last;

            if (lastMessage['is_new'] == true &&
                lastMessage['receiverEmail'] == userEmail) {
              uniqueSenders.add(lastMessage['senderEmail']);
            }
          }
        }
      }

      // Yield the count of unique senders
      yield uniqueSenders.length;
    }
  }
}
