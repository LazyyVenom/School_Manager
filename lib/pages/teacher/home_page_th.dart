import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:school_manager/additional_features.dart';
import 'package:school_manager/chat/chats_displayer.dart';
import 'package:school_manager/pages/teacher/student_id_create.dart';
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
    (Route<dynamic> route) => false,
  );
}

class HomePageTh extends StatelessWidget {
  const HomePageTh({super.key});

  @override
  Widget build(BuildContext context) {
    final _current_user = Provider.of<CurrentUser>(context, listen: false);
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
                        "Class Teacher ${_current_user.className} Std ${_current_user.section}",
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
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.deepPurple[50]),
                    ),
                    onPressed: () {
                      return;
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Change Password"),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red[50]),
                      foregroundColor:
                          MaterialStatePropertyAll(Colors.red[400]),
                      overlayColor: MaterialStatePropertyAll(Colors.red[100]),
                    ),
                    onPressed: () {
                      logout(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Log Out"),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(),
            const SizedBox(height: 6),
            Text(
              "Perform Tasks",
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
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ChatsDisplay(
                                        type: 'Management')));
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
                                  )
                                ],
                              )),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ChatsDisplay(type: 'Students')));
                          },
                          child: Card(
                            color: Colors.deepPurple[50],
                            child: const Column(
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const StudentRegisterPage()),
                            );
                          },
                          child: Card(
                            color: Colors.deepPurple[50],
                            child: const Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Create Student's Account"),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.assignment_ind,
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
