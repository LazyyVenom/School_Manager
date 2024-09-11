import 'package:flutter/material.dart';

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
  String? accountType;
  String? className;
  String? section;
  String? password;

  void updateUser({
    required String newGmail,
    required String newName,
    required String newAccountType,
    required String newClassName,
    required String newSection,
    required String newPassword,
  }) {
    gmail = newGmail;
    name = newName;
    accountType = newAccountType;
    className = newClassName;
    section = newSection;
    password = newPassword;

    notifyListeners();
  }
}