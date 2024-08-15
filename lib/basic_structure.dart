import 'package:flutter/material.dart';
import 'package:school_manager/alert_page.dart';
import 'package:school_manager/assignment_page.dart';
import 'package:school_manager/attendance_page.dart';
import 'package:school_manager/bus_tracking_page.dart';
import 'package:school_manager/home_page.dart';

class BasicStructure extends StatefulWidget {
  const BasicStructure({
    super.key,
  });

  @override
  State<BasicStructure> createState() => _BasicStructureState();
}

class _BasicStructureState extends State<BasicStructure> {
  int currentPage = 0;
  List<Widget> pages = const [
    HomePage(),
    AlertPage(),
    BusTrackingPage(),
    AssignmentPage(),
    AttendancePage()
  ];

  @override
  void initState() {
    currentPage = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("School_Name"),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: currentPage,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.deepPurple[100],
        selectedFontSize: 0,
        unselectedFontSize: 0,
        currentIndex: currentPage,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
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
            icon: Icon(Icons.bus_alert),
            label: "Bus Tracking",
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
