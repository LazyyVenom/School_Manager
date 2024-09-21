import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/chat/chats_displayer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_manager/pages/login_page.dart';

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


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    CurrentUser _current_user = Provider.of<CurrentUser>(context,listen: false);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 95,
              width: double.infinity,
              child: Card(
                color: Colors.deepPurple[50],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Text(
                          "Welcome ${_current_user.name}",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        "Class ${_current_user.className} Std ${_current_user.section}",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.deepPurple[50])),
                    onPressed: () {
                      return;
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Change Password"),
                    )),
                TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.deepPurple[50])),
                    onPressed: () {
                      return;
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Request Profile Edit"),
                    )),
                TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.red[50]),
                        foregroundColor:
                            MaterialStatePropertyAll(Colors.red[400]),
                        overlayColor:
                            MaterialStatePropertyAll(Colors.red[100])),
                    onPressed: () {
                      logout(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Log Out"),
                    )),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(),
            const SizedBox(height: 6),
            Text(
              "Recent Activities",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Divider(),
            const SizedBox(height: 6),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context, MaterialPageRoute(
                                builder: (context) => const ChatsDisplay(type: "Teachers")
                                )
                              );
                          },
                          child: Card(
                              color: Colors.deepPurple[50],
                              child: const Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text("Contact Teacher"),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Icon(
                                      Icons.person,
                                      size: 55,
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context, MaterialPageRoute(
                                builder: (context) => const ChatsDisplay(type: 'Management')
                                )
                              );
                          },
                          child: Card(
                            color: Colors.deepPurple[50],
                            child: const Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text("Contact Management"),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Icon(
                                    Icons.manage_accounts,
                                    size: 55,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: Card(
                            color: Colors.deepPurple[50],
                            child: const Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child:
                                      Text("Check Your Child's Progress Here"),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.bar_chart,
                                    size: 70,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}