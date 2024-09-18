import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission handler
import 'package:school_manager/auth/auth_gate.dart';
import 'package:school_manager/auth/auth_service.dart';
import 'package:school_manager/firebase_options.dart';
import 'package:school_manager/additional_features.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _requestPermissions();
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

Future<void> _requestPermissions() async {
  final status = await [
    Permission.camera,
    Permission.storage,
  ].request();

  if (status[Permission.camera]!.isDenied ||
      status[Permission.storage]!.isDenied) {
    print('Some permissions are denied.');
  }
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
