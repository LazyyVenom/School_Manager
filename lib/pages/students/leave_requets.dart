import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeaveApplicationPage extends StatefulWidget {
  const LeaveApplicationPage({Key? key}) : super(key: key);

  @override
  State<LeaveApplicationPage> createState() => _LeaveApplicationPageState();
}

class _LeaveApplicationPageState extends State<LeaveApplicationPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _reasonController = TextEditingController();
  int _totalLeaveDays = 0;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _calculateTotalLeaveDays();
      });
    }
  }

  void _calculateTotalLeaveDays() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        _totalLeaveDays = _endDate!.difference(_startDate!).inDays + 1;
      });
    }
  }

  void _sendLeaveRequest() {
    if (_startDate == null || _endDate == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields before sending the request')),
      );
      return;
    }

    // Firestore save logic
    FirebaseFirestore.instance.collection('leaveRequests').add({
      'startDate': _startDate,
      'endDate': _endDate,
      'reason': _reasonController.text,
      'totalLeaveDays': _totalLeaveDays,
      'email': 'userEmail@example.com', // Replace with actual user email
      'status': 'pending',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leave request sent successfully!')),
    );

    // Clear the fields
    setState(() {
      _startDate = null;
      _endDate = null;
      _reasonController.clear();
      _totalLeaveDays = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Application'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "This Leave Request will be sent to the School Teacher and School Nurse",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Start Date Picker
              _buildDateSelector("Start Date", _startDate, true),

              const SizedBox(height: 10),

              // End Date Picker
              _buildDateSelector("End Date", _endDate, false),

              const SizedBox(height: 20),

              // Total Leave Days
              if (_totalLeaveDays > 0)
                Text(
                  'Total Leave Days: $_totalLeaveDays',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 20),

              // Reason Text Field
              TextField(
                controller: _reasonController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  labelText: 'Reason for Leave',
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Send Button
              ElevatedButton.icon(
                onPressed: _sendLeaveRequest,
                icon: const Icon(Icons.send),
                label: const Text('Send Leave Request'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.deepPurple,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, bool isStartDate) {
    return GestureDetector(
      onTap: () => _selectDate(context, isStartDate),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.deepPurple[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.deepPurple),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? "Select $label" : DateFormat('yyyy-MM-dd').format(date),
              style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
            ),
            const Icon(Icons.calendar_today, color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }
}
