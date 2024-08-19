import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_manager/basic_structure.dart';
import 'package:school_manager/login_page.dart';

class InitialChecker extends StatelessWidget {
  const InitialChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading screen while waiting for the Future to complete
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            // User is already logged in, navigate to BasicStructure
            Future.microtask(() => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BasicStructure())));
          } else {
            // User is not logged in, navigate to LoginPage
            Future.microtask(() => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage())));
          }
          return const Center(
              child: CircularProgressIndicator(),
            ); // Return an empty widget while navigating
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
