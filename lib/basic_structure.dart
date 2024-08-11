import 'package:flutter/material.dart';

class BasicStructure extends StatelessWidget {
  const BasicStructure({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("School_Name"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("Hello World"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 0,
        unselectedFontSize: 0,
        iconSize: 26,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            backgroundColor: Colors.deepPurple
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_alert),
            label: "Alert",
            backgroundColor: Colors.deepPurple
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Assignment",
            backgroundColor: Colors.deepPurple
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Attendance",
            backgroundColor: Colors.deepPurple
          ),
        ],
      ),
    );
  }
}
