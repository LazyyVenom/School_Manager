import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/change_password.dart';
import 'package:school_manager/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class HomePageNurse extends StatelessWidget {
  const HomePageNurse({super.key});

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
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
                            style: Theme.of(context).textTheme.headline5?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Text(
                          "Nurse",
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Change Password button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.deepPurple[50]),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordPage(), // Pass userEmail if needed
                          ),
                        );
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
                        backgroundColor: MaterialStateProperty.all(Colors.red[50]),
                        foregroundColor: MaterialStateProperty.all(Colors.red[400]),
                        overlayColor: MaterialStateProperty.all(Colors.red[100]),
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
                  // You can navigate to the relevant screen if needed
                },
                child: Card(
                  color: Colors.orange[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
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
                          stream: getNewMessageCountStream(currentUser.gmail!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
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
                                backgroundColor: count > 0 ? Colors.red[400] : Colors.grey,
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
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Leave Request card
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Leave Request",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Add any additional content related to leave requests here
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<int> getNewMessageCountStream(String userEmail) async* {
    Set<String> uniqueSenders = {};

    await for (var snapshot in FirebaseFirestore.instance.collection('chat_rooms').snapshots()) {
      uniqueSenders.clear(); // Clear the previous senders

      for (var doc in snapshot.docs) {
        String chatRoomId = doc.id;

        if (chatRoomId.contains(userEmail)) {
          var messages = doc['messages'] as List<dynamic>?;

          if (messages != null && messages.isNotEmpty) {
            var lastMessage = messages.last;

            if (lastMessage['is_new'] == true && lastMessage['receiverEmail'] == userEmail) {
              uniqueSenders.add(lastMessage['senderEmail']);
            }
          }
        }
      }

      yield uniqueSenders.length; // Yield the count of unique senders
    }
  }
}
