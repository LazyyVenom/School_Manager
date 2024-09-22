import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DisplayStudentProgress extends StatefulWidget {
  final String studentEmail;
  final String className;
  final String sectionName;

  const DisplayStudentProgress({
    required this.studentEmail,
    required this.className,
    required this.sectionName,
    Key? key,
  }) : super(key: key);

  @override
  _DisplayStudentProgressState createState() => _DisplayStudentProgressState();
}

class _DisplayStudentProgressState extends State<DisplayStudentProgress> {
  String? _selectedExam;
  List<String> _exams = [];
  Map<String, double> _marksData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('exams')
          .doc('${widget.className}_${widget.sectionName}')
          .get();

      if (snapshot.exists) {
        // Get exam names directly from the keys
        List<String> examList = snapshot
            .data()!
            .keys
            .where((key) => key != 'className' && key != 'sectionName')
            .toList();
        setState(() {
          _exams = examList;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching exams: $e"),
          backgroundColor: Colors.red[200],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMarks() async {
    if (_selectedExam == null) return;

    setState(() {
      _isLoading = true;
      _marksData.clear();
    });

    try {
      DocumentSnapshot<Map<String, dynamic>> studentSnapshot =
          await FirebaseFirestore.instance
              .collection('studentMarks')
              .doc(widget.studentEmail)
              .get();

      if (studentSnapshot.exists) {
        var examData =
            studentSnapshot.data()?[_selectedExam] as List<dynamic>? ?? [];

        for (var subjectData in examData) {
          if (subjectData is Map<String, dynamic> &&
              subjectData.containsKey('subject') &&
              subjectData.containsKey('marks')) {
            double marks = (subjectData['marks'] is num)
                ? (subjectData['marks'] as num).toDouble()
                : 0.0;
            _marksData[subjectData['subject']] = marks;
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching marks: $e"),
          backgroundColor: Colors.red[200],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Progress of ${widget.studentEmail}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedExam,
              decoration: const InputDecoration(
                labelText: "Select Exam",
                border: OutlineInputBorder(),
              ),
              items: _exams.map((exam) {
                return DropdownMenuItem<String>(
                  value: exam,
                  child: Text(exam),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExam = value;
                  _fetchMarks();
                });
              },
            ),
            const SizedBox(height: 16.0),
            _isLoading
                ? const CircularProgressIndicator()
                : _marksData.isEmpty
                    ? const Text("No marks available for the selected exam.")
                    : Expanded(child: _buildSubjectPieCharts()),
          ],
        ),
      ),
    );
  }

  // Function to build multiple Pie Charts for each subject
  Widget _buildSubjectPieCharts() {
    return SingleChildScrollView(
      child: Column(
        children: _marksData.entries.map((entry) {
          double obtainedPercentage = (entry.value / 100) * 100;
          double remainingPercentage = 100 - obtainedPercentage;

          return Column(
            children: [
              SizedBox(
                width: 400, // Adjust the size of each pie chart
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.green[300],
                        value: obtainedPercentage,
                        title: "${obtainedPercentage.toStringAsFixed(1)}%",
                        radius: 55,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      PieChartSectionData(
                        color: Colors.red[300],
                        value: remainingPercentage,
                        title: "${remainingPercentage.toStringAsFixed(1)}%",
                        radius: 55,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              Text(
                entry.key, // Subject name
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16), // Space between charts
            ],
          );
        }).toList(),
      ),
    );
  }
}
