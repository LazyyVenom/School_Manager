import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/auth/auth_gate.dart';
import 'package:school_manager/auth/auth_service.dart';
import 'package:school_manager/firebase_options.dart';
import 'package:provider/provider.dart';

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
class CurrentUser extends ChangeNotifier {
  String? gmail;
  String? name;
  String? accountType; // e.g., "Student", "Teacher", "Admin"
  String? className;
  String? section;

  void updateUser({
    required String newGmail,
    required String newName,
    required String newAccountType,
    required String newClassName,
    required String newSection,
  }) {
    gmail = newGmail;
    name = newName;
    accountType = newAccountType;
    className = newClassName;
    section = newSection;

    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        ChangeNotifierProvider<CurrentUser>(
          create: (context) => CurrentUser(),
        ),
      ],
      child: const SchoolManagerApp(),
    ),
  );
}

class SchoolManagerApp extends StatelessWidget {
  const SchoolManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Manager',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
          },
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class SchoolManager extends StatefulWidget {
  const SchoolManager({super.key});

  @override
  State<SchoolManager> createState() => _SchoolManagerState();
}

class _SchoolManagerState extends State<SchoolManager> {
  @override
  Widget build(BuildContext context) {
    return const AuthGate();
  }
}
