import 'package:flutter/material.dart';
import 'package:school_manager/pages/students/alert_page_st.dart';
import 'package:school_manager/pages/students/assignment_page_st.dart';
import 'package:school_manager/pages/students/attendance_page_st.dart';
import 'package:school_manager/pages/bus_tracking_page.dart';
import 'package:school_manager/pages/students/home_page_st.dart';

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