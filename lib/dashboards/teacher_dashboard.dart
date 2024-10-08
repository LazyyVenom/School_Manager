import 'package:flutter/material.dart';
import 'package:school_manager/pages/teacher/alert_page_th.dart';
import 'package:school_manager/pages/teacher/assignment_page_th.dart';
import 'package:school_manager/pages/teacher/attendance_page_th.dart';
import 'package:school_manager/pages/bus_tracking_page.dart';
import 'package:school_manager/pages/teacher/home_page_th.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({
    super.key,
  });

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int currentPage = 0;
  List<Widget> pages = const [
    HomePageTh(),
    AlertPageTh(),
    BusTrackingPage(),
    AssignmentPageTh(),
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
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.deepPurple,
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
            icon: Icon(Icons.warning),
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
