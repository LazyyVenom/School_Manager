import "package:flutter/material.dart";
import "package:table_calendar/table_calendar.dart";

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            "Attendance",
            style: Theme.of(context).textTheme.displayMedium,
            ),
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: DateTime.now(),
          ),
          
        ],
      ),
    );
  }
}  