import 'package:flutter/material.dart';
import 'package:school_manager/pages/management/alert_page_mt.dart';
import 'package:school_manager/pages/management/home_page_mt.dart';

class NurseDashboard extends StatefulWidget {
  const NurseDashboard({
    super.key,
  });

  @override
  State<NurseDashboard> createState() => NurseDashboardState();
}

class NurseDashboardState extends State<NurseDashboard> {
  int currentPage = 0;
  List<Widget> pages = const [
    HomePageMt(),
    AlertPageMt(),
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
        backgroundColor: Colors.deepPurple,
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
          )
        ],
      ),
    );
  }
}
