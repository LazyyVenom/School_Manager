import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final List<DateTime> totalAttendance = [];
  final List<DateTime> presentAttendance = [];

  @override
  void initState() {
    super.initState();
    _generateRandomAttendance();
  }

  void _generateRandomAttendance() {
    DateTime firstDay = DateTime.utc(2023, 1, 1);
    DateTime lastDay = DateTime.now();
    Random random = Random();

    for (int i = 0; i < 100; i++) {
      DateTime randomDate = firstDay.add(Duration(days: random.nextInt(lastDay.difference(firstDay).inDays)));
      if (!totalAttendance.contains(randomDate)) {
        totalAttendance.add(randomDate);
      }
    }

    for (DateTime date in totalAttendance) {
      if (random.nextBool()) {
        presentAttendance.add(date);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Container(
            alignment: Alignment.center,
            child: Text(
              "Attendance",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 6),
          const Divider(),
          TableCalendar(
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            rowHeight: 50,
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2026, 1, 1),
            focusedDay: DateTime.now(),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (totalAttendance.contains(day)) {
                  bool isPresent = presentAttendance.contains(day);
                  return Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isPresent ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                      width: 35,
                      height: 35,
                      alignment: Alignment.center,
                      child: Text(
                        day.day.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 6),
          const Text(
            "Total Working Days: 89\nTotal Attendance: 80\nCurrent Percentage: 89.9%",
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }
}
